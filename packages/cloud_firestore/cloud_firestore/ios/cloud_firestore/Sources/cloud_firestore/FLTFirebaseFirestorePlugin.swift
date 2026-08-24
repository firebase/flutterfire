// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import FirebaseCore
import FirebaseFirestore
import Foundation

#if canImport(firebase_core)
  import firebase_core
#else
  import firebase_core_shared
#endif

#if canImport(cloud_firestore_objc)
  import cloud_firestore_objc
#endif

#if os(iOS)
  import Flutter
  import UIKit
#elseif os(macOS)
  import AppKit
  import FlutterMacOS
#endif

@objc(FLTFirebaseFirestorePlugin)
public class FLTFirebaseFirestorePlugin: NSObject, FlutterPlugin, FLTFirebasePluginProtocol,
  FirebaseFirestoreHostApi {
  private var messenger: FlutterBinaryMessenger
  private var transactions: [String: Transaction] = [:]
  private var eventChannels: [String: FlutterEventChannel] = [:]
  private var streamHandlers: [String: NSObject & FlutterStreamHandler] = [:]
  private var transactionHandlers: [String: TransactionStreamHandler] = [:]
  private let transactionLock = NSLock()

  static let serverTimestampMap = NSCache<NSNumber, NSString>()

  private static let codec = FlutterStandardMethodCodec(
    readerWriter: FirestoreMessagesPigeonCodecReaderWriter()
  )

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
    FLTFirebasePluginRegistry.sharedInstance().register(self)
  }

  @objc
  public static func register(with registrar: FlutterPluginRegistrar) {
    #if os(macOS)
      let binaryMessenger = registrar.messenger
    #else
      let binaryMessenger = registrar.messenger()
    #endif

    let instance = FLTFirebaseFirestorePlugin(messenger: binaryMessenger)
    #if os(iOS)
      registrar.publish(instance)
      FLTFirestoreClientLanguage.setClientLanguage("gl-dart/\(versionNumber)")
    #endif

    FirebaseFirestoreHostApiSetup.setUp(binaryMessenger: binaryMessenger, api: instance)
  }

  public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
    cleanupEventListeners()
  }

  public func didReinitializeFirebaseCore(_ completion: @escaping () -> Void) {
    cleanupEventListeners()
    cleanupFirestoreInstances(completion)
  }

  public func pluginConstants(for firebaseApp: FirebaseApp) -> [AnyHashable: Any] {
    [:]
  }

  @objc public func firebaseLibraryName() -> String {
    kFirebaseFirestoreLibraryName
  }

  @objc public func firebaseLibraryVersion() -> String {
    versionNumber
  }

  @objc public func flutterChannelName() -> String {
    kFLTFirebaseFirestoreChannelName
  }

  private func cleanupEventListeners() {
    for channel in eventChannels.values {
      channel.setStreamHandler(nil)
    }
    eventChannels.removeAll()
    for handler in streamHandlers.values {
      _ = handler.onCancel(withArguments: nil)
    }
    streamHandlers.removeAll()
    transactionLock.lock()
    transactions.removeAll()
    transactionLock.unlock()
  }

  private func cleanupFirestoreInstances(_ completion: (() -> Void)?) {
    if FirebaseFirestoreUtils.count > 0 {
      FirebaseFirestoreUtils.cleanupFirestoreInstances(completion)
    } else {
      completion?()
    }
  }

  @discardableResult
  private func registerEventChannel(prefix: String,
                                    identifier: String = UUID().uuidString.lowercased(),
                                    streamHandler: NSObject & FlutterStreamHandler) -> String {
    let channelName = "\(prefix)/\(identifier)"
    let channel = FlutterEventChannel(
      name: channelName,
      binaryMessenger: messenger,
      codec: Self.codec
    )
    channel.setStreamHandler(streamHandler)
    eventChannels[identifier] = channel
    streamHandlers[identifier] = streamHandler
    return identifier
  }

  private func firestore(from pigeonApp: FirestorePigeonFirebaseApp) -> Firestore {
    objc_sync_enter(self)
    defer { objc_sync_exit(self) }

    let app = FLTFirebasePlugin.firebaseAppNamed(pigeonApp.appName)!
    if let cached = FirebaseFirestoreUtils.firestoreInstance(
      appName: app.name, databaseURL: pigeonApp.databaseURL
    ) {
      return cached
    }

    let settings = FirestoreSettings()
    if let persistenceEnabled = pigeonApp.settings.persistenceEnabled {
      var size = NSNumber(value: FirestoreCacheSizeUnlimited)
      if let cacheSizeBytes = pigeonApp.settings.cacheSizeBytes, cacheSizeBytes != -1 {
        size = NSNumber(value: cacheSizeBytes)
      }
      if persistenceEnabled {
        settings.cacheSettings = PersistentCacheSettings(sizeBytes: size)
      } else {
        settings.cacheSettings = MemoryCacheSettings(
          garbageCollectorSettings: MemoryLRUGCSettings()
        )
      }
    }

    if let host = pigeonApp.settings.host {
      settings.host = host
      if let sslEnabled = pigeonApp.settings.sslEnabled {
        settings.isSSLEnabled = sslEnabled
      }
    }

    settings.dispatchQueue = FirebaseFirestoreReader.firestoreQueue

    let firestore = Firestore.firestore(app: app, database: pigeonApp.databaseURL)
    firestore.settings = settings
    FirebaseFirestoreUtils.setCachedInstance(
      firestore, appName: app.name, databaseURL: pigeonApp.databaseURL
    )
    return firestore
  }

  private func completeOnError<T>(_ error: Error,
                                  _ completion: @escaping (Result<T, Error>) -> Void) {
    completion(.failure(FirebaseFirestoreUtils.flutterError(from: error)))
  }

  func loadBundle(app: FirestorePigeonFirebaseApp, bundle: FlutterStandardTypedData,
                  completion: @escaping (Result<String, Error>) -> Void) {
    let firestore = firestore(from: app)
    let identifier = registerEventChannel(
      prefix: kFLTFirebaseFirestoreLoadBundleChannelName,
      streamHandler: LoadBundleStreamHandler(firestore: firestore, bundle: bundle)
    )
    completion(.success(identifier))
  }

  func namedQueryGet(app: FirestorePigeonFirebaseApp, name: String, options: InternalGetOptions,
                     completion: @escaping (Result<InternalQuerySnapshot, Error>) -> Void) {
    let firestore = firestore(from: app)
    let source = PigeonParser.parseSource(options.source)
    let serverTimestampBehavior = PigeonParser.parseServerTimestampBehavior(
      options.serverTimestampBehavior
    )

    firestore.getQuery(named: name) { query in
      guard let query else {
        completion(
          .failure(
            FlutterError(
              code: "non-existent-named-query",
              message:
              "Named query has not been found. Please check it has been loaded properly via loadBundle().",
              details: nil
            )
          )
        )
        return
      }
      query.getDocuments(source: source) { snapshot, error in
        if let error {
          self.completeOnError(error, completion)
        } else if let snapshot {
          completion(
            .success(
              PigeonParser.toPigeonQuerySnapshot(
                snapshot, serverTimestampBehavior: serverTimestampBehavior
              )
            )
          )
        }
      }
    }
  }

  func clearPersistence(app: FirestorePigeonFirebaseApp,
                        completion: @escaping (Result<Void, Error>) -> Void) {
    firestore(from: app).clearPersistence { error in
      if let error {
        self.completeOnError(error, completion)
      } else {
        completion(.success(()))
      }
    }
  }

  func disableNetwork(app: FirestorePigeonFirebaseApp,
                      completion: @escaping (Result<Void, Error>) -> Void) {
    firestore(from: app).disableNetwork { error in
      if let error {
        self.completeOnError(error, completion)
      } else {
        completion(.success(()))
      }
    }
  }

  func enableNetwork(app: FirestorePigeonFirebaseApp,
                     completion: @escaping (Result<Void, Error>) -> Void) {
    firestore(from: app).enableNetwork { error in
      if let error {
        self.completeOnError(error, completion)
      } else {
        completion(.success(()))
      }
    }
  }

  func terminate(app: FirestorePigeonFirebaseApp,
                 completion: @escaping (Result<Void, Error>) -> Void) {
    let firestore = firestore(from: app)
    firestore.terminate { error in
      if let error {
        self.completeOnError(error, completion)
      } else {
        let extensionInstance = FirebaseFirestoreUtils.cachedInstance(for: firestore)
        FirebaseFirestoreUtils.destroyCachedInstance(
          appName: firestore.app.name, databaseURL: extensionInstance.databaseURL
        )
        completion(.success(()))
      }
    }
  }

  func waitForPendingWrites(app: FirestorePigeonFirebaseApp,
                            completion: @escaping (Result<Void, Error>) -> Void) {
    firestore(from: app).waitForPendingWrites { error in
      if let error {
        self.completeOnError(error, completion)
      } else {
        completion(.success(()))
      }
    }
  }

  func setIndexConfiguration(app: FirestorePigeonFirebaseApp, indexConfiguration: String,
                             completion: @escaping (Result<Void, Error>) -> Void) {
    firestore(from: app).setIndexConfiguration(indexConfiguration) { error in
      if let error {
        self.completeOnError(error, completion)
      } else {
        completion(.success(()))
      }
    }
  }

  func setLoggingEnabled(loggingEnabled: Bool,
                         completion: @escaping (Result<Void, Error>) -> Void) {
    Firestore.enableLogging(loggingEnabled)
    completion(.success(()))
  }

  func snapshotsInSyncSetup(app: FirestorePigeonFirebaseApp,
                            completion: @escaping (Result<String, Error>) -> Void) {
    let firestore = firestore(from: app)
    let identifier = registerEventChannel(
      prefix: kFLTFirebaseFirestoreSnapshotsInSyncEventChannelName,
      streamHandler: SnapshotsInSyncStreamHandler(firestore: firestore)
    )
    completion(.success(identifier))
  }

  func transactionCreate(app: FirestorePigeonFirebaseApp, timeout: Int64, maxAttempts: Int64,
                         completion: @escaping (Result<String, Error>) -> Void) {
    let firestore = firestore(from: app)
    let transactionId = UUID().uuidString.lowercased()
    let handler = TransactionStreamHandler(
      id: transactionId,
      firestore: firestore,
      timeout: Int(timeout),
      maxAttempts: Int(maxAttempts),
      started: { [weak self] transaction in
        guard let self else { return }
        self.transactionLock.lock()
        self.transactions[transactionId] = transaction
        self.transactionLock.unlock()
      },
      ended: { [weak self] in
        guard let self else { return }
        self.transactionLock.lock()
        self.transactions.removeValue(forKey: transactionId)
        self.transactionLock.unlock()
      }
    )
    transactionHandlers[transactionId] = handler
    let identifier = registerEventChannel(
      prefix: kFLTFirebaseFirestoreTransactionChannelName,
      identifier: transactionId,
      streamHandler: handler
    )
    completion(.success(identifier))
  }

  func transactionStoreResult(transactionId: String, resultType: InternalTransactionResult,
                              commands: [InternalTransactionCommand?]?,
                              completion: @escaping (Result<Void, Error>) -> Void) {
    transactionHandlers[transactionId]?.receiveTransactionResponse(resultType, commands: commands)
    completion(.success(()))
  }

  func transactionGet(app: FirestorePigeonFirebaseApp, transactionId: String, path: String,
                      completion: @escaping (Result<InternalDocumentSnapshot, Error>) -> Void) {
    DispatchQueue.global(qos: .default).async {
      let firestore = self.firestore(from: app)
      let document = firestore.document(path)

      self.transactionLock.lock()
      let transaction = self.transactions[transactionId]
      self.transactionLock.unlock()

      guard let transaction else {
        completion(
          .failure(
            FlutterError(
              code: "missing-transaction",
              message:
              "An error occurred while getting the native transaction. It could be caused by a timeout in a preceding transaction operation.",
              details: nil
            )
          )
        )
        return
      }

      do {
        let snapshot = try transaction.getDocument(document)
        completion(
          .success(
            PigeonParser.toPigeonDocumentSnapshot(
              snapshot, serverTimestampBehavior: .none
            )
          )
        )
      } catch {
        self.completeOnError(error, completion)
      }
    }
  }

  func documentReferenceSet(app: FirestorePigeonFirebaseApp, request: DocumentReferenceRequest,
                            completion: @escaping (Result<Void, Error>) -> Void) {
    let document = firestore(from: app).document(request.path)
    let data = request.data as? [String: Any] ?? [:]
    let finish: (Error?) -> Void = { error in
      if let error {
        self.completeOnError(error, completion)
      } else {
        completion(.success(()))
      }
    }

    if request.option?.merge == true {
      document.setData(data, merge: true, completion: finish)
    } else if let mergeFields = request.option?.mergeFields {
      document.setData(
        data, mergeFields: PigeonParser.parseFieldPath(mergeFields), completion: finish
      )
    } else {
      document.setData(data, completion: finish)
    }
  }

  func documentReferenceUpdate(app: FirestorePigeonFirebaseApp, request: DocumentReferenceRequest,
                               completion: @escaping (Result<Void, Error>) -> Void) {
    let document = firestore(from: app).document(request.path)
    let data = request.data as? [AnyHashable: Any] ?? [:]
    document.updateData(data) { error in
      if let error {
        self.completeOnError(error, completion)
      } else {
        completion(.success(()))
      }
    }
  }

  func documentReferenceGet(app: FirestorePigeonFirebaseApp, request: DocumentReferenceRequest,
                            completion: @escaping (Result<InternalDocumentSnapshot, Error>)
                              -> Void) {
    let document = firestore(from: app).document(request.path)
    let source = PigeonParser.parseSource(request.source ?? .serverAndCache)
    let serverTimestampBehavior = PigeonParser.parseServerTimestampBehavior(
      request.serverTimestampBehavior ?? .none
    )
    document.getDocument(source: source) { snapshot, error in
      if let error {
        self.completeOnError(error, completion)
      } else if let snapshot {
        completion(
          .success(
            PigeonParser.toPigeonDocumentSnapshot(
              snapshot, serverTimestampBehavior: serverTimestampBehavior
            )
          )
        )
      }
    }
  }

  func documentReferenceDelete(app: FirestorePigeonFirebaseApp, request: DocumentReferenceRequest,
                               completion: @escaping (Result<Void, Error>) -> Void) {
    firestore(from: app).document(request.path).delete { error in
      if let error {
        self.completeOnError(error, completion)
      } else {
        completion(.success(()))
      }
    }
  }

  func queryGet(app: FirestorePigeonFirebaseApp, path: String, isCollectionGroup: Bool,
                parameters: InternalQueryParameters, options: InternalGetOptions,
                completion: @escaping (Result<InternalQuerySnapshot, Error>) -> Void) {
    let firestore = firestore(from: app)
    guard
      let query = PigeonParser.parseQuery(
        parameters: parameters, firestore: firestore, path: path,
        isCollectionGroup: isCollectionGroup
      )
    else {
      completion(
        .failure(
          FlutterError(
            code: "error-parsing",
            message:
            "An error occurred while parsing query arguments, this is most likely an error with this SDK.",
            details: nil
          )
        )
      )
      return
    }

    let source = PigeonParser.parseSource(options.source)
    let serverTimestampBehavior = PigeonParser.parseServerTimestampBehavior(
      options.serverTimestampBehavior
    )
    query.getDocuments(source: source) { snapshot, error in
      if let error {
        self.completeOnError(error, completion)
      } else if let snapshot {
        completion(
          .success(
            PigeonParser.toPigeonQuerySnapshot(
              snapshot, serverTimestampBehavior: serverTimestampBehavior
            )
          )
        )
      }
    }
  }

  func aggregateQuery(app: FirestorePigeonFirebaseApp, path: String,
                      parameters: InternalQueryParameters,
                      source: AggregateSource, queries: [AggregateQuery?], isCollectionGroup: Bool,
                      completion: @escaping (Result<[AggregateQueryResponse?], Error>) -> Void) {
    let firestore = firestore(from: app)
    guard
      let query = PigeonParser.parseQuery(
        parameters: parameters, firestore: firestore, path: path,
        isCollectionGroup: isCollectionGroup
      )
    else {
      completion(
        .failure(
          FlutterError(
            code: "error-parsing",
            message:
            "An error occurred while parsing query arguments, this is most likely an error with this SDK.",
            details: nil
          )
        )
      )
      return
    }

    var aggregateFields: [AggregateField] = []
    for queryRequest in queries.compactMap({ $0 }) {
      switch queryRequest.type {
      case .count:
        aggregateFields.append(AggregateField.count())
      case .sum:
        if let field = queryRequest.field {
          aggregateFields.append(AggregateField.sum(field))
        }
      case .average:
        if let field = queryRequest.field {
          aggregateFields.append(AggregateField.average(field))
        }
      }
    }

    let firebaseAggregateQuery: FirebaseFirestore.AggregateQuery = query.aggregate(
      aggregateFields
    )
    firebaseAggregateQuery.getAggregation(source: .server) { snapshot, error in
      if let error {
        self.completeOnError(error, completion)
        return
      }
      guard let snapshot else {
        completion(.success([]))
        return
      }

      var responses: [AggregateQueryResponse?] = []
      for queryRequest in queries.compactMap({ $0 }) {
        switch queryRequest.type {
        case .count:
          responses.append(
            AggregateQueryResponse(
              type: .count, field: nil, value: snapshot.count.doubleValue
            )
          )
        case .sum:
          let value =
            snapshot.get(AggregateField.sum(queryRequest.field ?? "")) as? NSNumber
          responses.append(
            AggregateQueryResponse(
              type: .sum, field: queryRequest.field, value: value?.doubleValue
            )
          )
        case .average:
          let value =
            snapshot.get(AggregateField.average(queryRequest.field ?? "")) as? NSNumber
          responses.append(
            AggregateQueryResponse(
              type: .average, field: queryRequest.field, value: value?.doubleValue
            )
          )
        }
      }
      completion(.success(responses))
    }
  }

  func writeBatchCommit(app: FirestorePigeonFirebaseApp, writes: [InternalTransactionCommand?],
                        completion: @escaping (Result<Void, Error>) -> Void) {
    let firestore = firestore(from: app)
    let batch = firestore.batch()
    for write in writes.compactMap({ $0 }) {
      let reference = firestore.document(write.path)
      switch write.type {
      case .get:
        break
      case .deleteType:
        batch.deleteDocument(reference)
      case .update:
        if let data = write.data as? [AnyHashable: Any] {
          batch.updateData(data, forDocument: reference)
        }
      case .set:
        let data = write.data as? [String: Any] ?? [:]
        if write.option?.merge == true {
          batch.setData(data, forDocument: reference, merge: true)
        } else if let mergeFields = write.option?.mergeFields {
          batch.setData(
            data, forDocument: reference, mergeFields: PigeonParser.parseFieldPath(mergeFields)
          )
        } else {
          batch.setData(data, forDocument: reference)
        }
      }
    }
    batch.commit { error in
      if let error {
        self.completeOnError(error, completion)
      } else {
        completion(.success(()))
      }
    }
  }

  func querySnapshot(app: FirestorePigeonFirebaseApp, path: String, isCollectionGroup: Bool,
                     parameters: InternalQueryParameters, options: InternalGetOptions,
                     includeMetadataChanges: Bool, source: ListenSource,
                     completion: @escaping (Result<String, Error>) -> Void) {
    let firestore = firestore(from: app)
    let query = PigeonParser.parseQuery(
      parameters: parameters, firestore: firestore, path: path, isCollectionGroup: isCollectionGroup
    )
    if query == nil {
      completion(
        .failure(
          FlutterError(
            code: "error-parsing",
            message:
            "An error occurred while parsing query arguments, this is most likely an error with this SDK.",
            details: nil
          )
        )
      )
      return
    }

    let identifier = registerEventChannel(
      prefix: kFLTFirebaseFirestoreQuerySnapshotEventChannelName,
      streamHandler: QuerySnapshotStreamHandler(
        firestore: firestore,
        query: query,
        includeMetadataChanges: includeMetadataChanges,
        serverTimestampBehavior: PigeonParser.parseServerTimestampBehavior(
          options.serverTimestampBehavior
        ),
        source: PigeonParser.parseListenSource(source)
      )
    )
    completion(.success(identifier))
  }

  func documentReferenceSnapshot(app: FirestorePigeonFirebaseApp,
                                 parameters: DocumentReferenceRequest,
                                 includeMetadataChanges: Bool, source: ListenSource,
                                 completion: @escaping (Result<String, Error>) -> Void) {
    let firestore = firestore(from: app)
    let document = firestore.document(parameters.path)
    let identifier = registerEventChannel(
      prefix: kFLTFirebaseFirestoreDocumentSnapshotEventChannelName,
      streamHandler: DocumentSnapshotStreamHandler(
        firestore: firestore,
        reference: document,
        includeMetadataChanges: includeMetadataChanges,
        serverTimestampBehavior: PigeonParser.parseServerTimestampBehavior(
          parameters.serverTimestampBehavior ?? .none
        ),
        source: PigeonParser.parseListenSource(source)
      )
    )
    completion(.success(identifier))
  }

  func persistenceCacheIndexManagerRequest(app: FirestorePigeonFirebaseApp,
                                           request: PersistenceCacheIndexManagerRequest,
                                           completion: @escaping (Result<Void, Error>) -> Void) {
    if let manager = firestore(from: app).persistentCacheIndexManager {
      switch request {
      case .enableIndexAutoCreation:
        manager.enableIndexAutoCreation()
      case .disableIndexAutoCreation:
        manager.disableIndexAutoCreation()
      case .deleteAllIndexes:
        manager.deleteAllIndexes()
      }
    } else {
      NSLog("FLTFirebaseFirestore: `PersistentCacheIndexManager` is not available.")
    }
    completion(.success(()))
  }

  func executePipeline(app: FirestorePigeonFirebaseApp, stages: [[String?: Any?]?],
                       options: [String?: Any?]?,
                       completion: @escaping (Result<InternalPipelineSnapshot, Error>) -> Void) {
    let firestore = firestore(from: app)
    let mappedStages: [[String: Any?]] = stages.compactMap { stage in
      guard let stage else { return nil }
      var mapped: [String: Any?] = [:]
      for (key, value) in stage {
        if let key {
          mapped[key] = value
        }
      }
      return mapped
    }
    var mappedOptions: [String: Any?]?
    if let options {
      var mapped: [String: Any?] = [:]
      for (key, value) in options {
        if let key {
          mapped[key] = value
        }
      }
      mappedOptions = mapped
    }

    PipelineParser.executePipeline(
      firestore: firestore, stages: mappedStages, options: mappedOptions
    ) { snapshot, error in
      if let error {
        self.completeOnError(error, completion)
        return
      }
      guard let snapshot else {
        completion(
          .failure(
            FlutterError(
              code: "error",
              message: "Pipeline execution returned no result",
              details: nil
            )
          )
        )
        return
      }

      func timestampToMs(_ value: Any?) -> Int64? {
        if value == nil || value is NSNull { return nil }
        if let number = value as? NSNumber { return number.int64Value }
        if let timestamp = value as? Timestamp {
          return timestamp.seconds * 1000 + Int64(timestamp.nanoseconds) / 1_000_000
        }
        return nil
      }

      var pigeonResults: [InternalPipelineResult?] = []
      if let results = (snapshot as AnyObject).value(forKey: "results") as? [Any] {
        for result in results {
          let object = result as AnyObject
          let ref = object.value(forKey: "reference") as AnyObject?
          let path =
            (ref?.value(forKey: "path") as? String)
              ?? (object.value(forKey: "documentID") as? String)
          let data = object.value(forKey: "data") as? [String: Any]
          let mappedData: [String?: Any?]? = data.map {
            Dictionary(uniqueKeysWithValues: $0.map { ($0.key as String?, $0.value as Any?) })
          }
          pigeonResults.append(
            InternalPipelineResult(
              documentPath: path,
              createTime: timestampToMs(object.value(forKey: "create_time")),
              updateTime: timestampToMs(object.value(forKey: "update_time")),
              data: mappedData
            )
          )
        }
      }

      var executionTime = timestampToMs((snapshot as AnyObject).value(forKey: "execution_time"))
      if executionTime == nil {
        executionTime = Int64(Date().timeIntervalSince1970 * 1000)
      }
      completion(
        .success(
          InternalPipelineSnapshot(results: pigeonResults, executionTime: executionTime ?? 0)
        )
      )
    }
  }
}
