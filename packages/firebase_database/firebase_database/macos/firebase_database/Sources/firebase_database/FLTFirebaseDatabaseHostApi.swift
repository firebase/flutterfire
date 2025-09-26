// Copyright 2025 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import FirebaseCore
import FirebaseDatabase
import FlutterMacOS
import Foundation

#if canImport(firebase_core)
  import firebase_core
#else
  import firebase_core_shared
#endif

@objc class FLTFirebaseDatabaseHostApi: NSObject, FirebaseDatabaseHostApi {
  private static var cachedDatabaseInstances: [String: Database] = [:]
  private var streamHandlers: [String: FLTFirebaseDatabaseObserveStreamHandler] = [:]
  private var binaryMessenger: FlutterBinaryMessenger
  private var listenerCount: Int = 0

  init(binaryMessenger: FlutterBinaryMessenger) {
    self.binaryMessenger = binaryMessenger
    super.init()
  }

  // MARK: - Database Management

  func goOnline(app: DatabasePigeonFirebaseApp, completion: @escaping (Result<Void, Error>) -> Void)
  {
    let database = getDatabaseFromPigeonApp(app)
    database.goOnline()
    completion(.success(()))
  }

  func goOffline(app: DatabasePigeonFirebaseApp,
                 completion: @escaping (Result<Void, Error>) -> Void) {
    let database = getDatabaseFromPigeonApp(app)
    database.goOffline()
    completion(.success(()))
  }

  func setPersistenceEnabled(app: DatabasePigeonFirebaseApp, enabled: Bool,
                             completion: @escaping (Result<Void, Error>) -> Void) {
    let database = getDatabaseFromPigeonApp(app)
    database.isPersistenceEnabled = enabled
    completion(.success(()))
  }

  func setPersistenceCacheSizeBytes(app: DatabasePigeonFirebaseApp, cacheSize: Int64,
                                    completion: @escaping (Result<Void, Error>) -> Void) {
    let database = getDatabaseFromPigeonApp(app)
    database.persistenceCacheSizeBytes = UInt(cacheSize)
    completion(.success(()))
  }

  func setLoggingEnabled(app: DatabasePigeonFirebaseApp, enabled: Bool,
                         completion: @escaping (Result<Void, Error>) -> Void) {
    Database.setLoggingEnabled(enabled)
    completion(.success(()))
  }

  func useDatabaseEmulator(app: DatabasePigeonFirebaseApp, host: String, port: Int64,
                           completion: @escaping (Result<Void, Error>) -> Void) {
    let database = getDatabaseFromPigeonApp(app)
    database.useEmulator(withHost: host, port: Int(port))
    completion(.success(()))
  }

  func ref(app: DatabasePigeonFirebaseApp, path: String?,
           completion: @escaping (Result<DatabaseReferencePlatform, Error>) -> Void) {
    let database = getDatabaseFromPigeonApp(app)
    let reference = database.reference(withPath: path ?? "")
    let result = DatabaseReferencePlatform(path: reference.url)
    completion(.success(result))
  }

  func refFromURL(app: DatabasePigeonFirebaseApp, url: String,
                  completion: @escaping (Result<DatabaseReferencePlatform, Error>) -> Void) {
    let database = getDatabaseFromPigeonApp(app)
    let reference = database.reference(fromURL: url)
    let result = DatabaseReferencePlatform(path: reference.url)
    completion(.success(result))
  }

  func purgeOutstandingWrites(app: DatabasePigeonFirebaseApp,
                              completion: @escaping (Result<Void, Error>) -> Void) {
    let database = getDatabaseFromPigeonApp(app)
    database.purgeOutstandingWrites()
    completion(.success(()))
  }

  // MARK: - Database Reference Operations

  func databaseReferenceSet(app: DatabasePigeonFirebaseApp, request: DatabaseReferenceRequest,
                            completion: @escaping (Result<Void, Error>) -> Void) {
    let database = getDatabaseFromPigeonApp(app)
    let reference = database.reference(withPath: request.path)

    reference.setValue(request.value) { error, _ in
      if let error {
        completion(.failure(error))
      } else {
        completion(.success(()))
      }
    }
  }

  func databaseReferenceSetWithPriority(app: DatabasePigeonFirebaseApp,
                                        request: DatabaseReferenceRequest,
                                        completion: @escaping (Result<Void, Error>) -> Void) {
    let database = getDatabaseFromPigeonApp(app)
    let reference = database.reference(withPath: request.path)

    reference.setValue(request.value, andPriority: request.priority) { error, _ in
      if let error {
        completion(.failure(error))
      } else {
        completion(.success(()))
      }
    }
  }

  func databaseReferenceUpdate(app: DatabasePigeonFirebaseApp, request: UpdateRequest,
                               completion: @escaping (Result<Void, Error>) -> Void) {
    let database = getDatabaseFromPigeonApp(app)
    let reference = database.reference(withPath: request.path)

    // Convert [String: Any?] to [String: Any] for Firebase
    let values = request.value.compactMapValues { $0 }

    reference.updateChildValues(values) { error, _ in
      if let error {
        completion(.failure(error))
      } else {
        completion(.success(()))
      }
    }
  }

  func databaseReferenceSetPriority(app: DatabasePigeonFirebaseApp,
                                    request: DatabaseReferenceRequest,
                                    completion: @escaping (Result<Void, Error>) -> Void) {
    let database = getDatabaseFromPigeonApp(app)
    let reference = database.reference(withPath: request.path)

    reference.setPriority(request.priority) { error, _ in
      if let error {
        completion(.failure(error))
      } else {
        completion(.success(()))
      }
    }
  }

  func databaseReferenceRunTransaction(app: DatabasePigeonFirebaseApp, request: TransactionRequest,
                                       completion: @escaping (Result<Void, Error>) -> Void) {
    let database = getDatabaseFromPigeonApp(app)
    let reference = database.reference(withPath: request.path)

    reference.runTransactionBlock { currentData in
      let semaphore = DispatchSemaphore(value: 0)
      var transactionResult: TransactionHandlerResult?

      // Call the Flutter transaction handler
      let flutterApi = FirebaseDatabaseFlutterApi(binaryMessenger: self.binaryMessenger)
      flutterApi.callTransactionHandler(
        transactionKey: request.transactionKey,
        snapshotValue: currentData.value
      ) { result in
        switch result {
        case let .success(handlerResult):
          transactionResult = handlerResult
        case let .failure(error):
          print("Transaction handler error: \(error)")
          transactionResult = TransactionHandlerResult(value: nil, aborted: true, exception: true)
        }
        semaphore.signal()
      }

      semaphore.wait()

      guard let result = transactionResult else {
        return TransactionResult.abort()
      }

      if result.aborted || result.exception {
        return TransactionResult.abort()
      }

      currentData.value = result.value
      return TransactionResult.success(withValue: currentData)
    } andCompletionBlock: { error, committed, snapshot in
      if let error {
        completion(.failure(error))
      } else {
        completion(.success(()))
      }
    }
  }

  func databaseReferenceGetTransactionResult(app: DatabasePigeonFirebaseApp, transactionKey: Int64,
                                             completion: @escaping (Result<[String: Any?], Error>)
                                               -> Void) {
    // This method is used to get transaction results, but in our implementation
    // we handle transactions synchronously, so we return an empty result
    completion(.success([:]))
  }

  // MARK: - OnDisconnect Operations

  func onDisconnectSet(app: DatabasePigeonFirebaseApp, request: DatabaseReferenceRequest,
                       completion: @escaping (Result<Void, Error>) -> Void) {
    let database = getDatabaseFromPigeonApp(app)
    let reference = database.reference(withPath: request.path)

    reference.onDisconnectSetValue(request.value) { error, _ in
      if let error {
        completion(.failure(error))
      } else {
        completion(.success(()))
      }
    }
  }

  func onDisconnectSetWithPriority(app: DatabasePigeonFirebaseApp,
                                   request: DatabaseReferenceRequest,
                                   completion: @escaping (Result<Void, Error>) -> Void) {
    let database = getDatabaseFromPigeonApp(app)
    let reference = database.reference(withPath: request.path)

    reference.onDisconnectSetValue(request.value, andPriority: request.priority) { error, _ in
      if let error {
        completion(.failure(error))
      } else {
        completion(.success(()))
      }
    }
  }

  func onDisconnectUpdate(app: DatabasePigeonFirebaseApp, request: UpdateRequest,
                          completion: @escaping (Result<Void, Error>) -> Void) {
    let database = getDatabaseFromPigeonApp(app)
    let reference = database.reference(withPath: request.path)

    // Convert [String: Any?] to [String: Any] for Firebase
    let values = request.value.compactMapValues { $0 }

    reference.onDisconnectUpdateChildValues(values) { error, _ in
      if let error {
        completion(.failure(error))
      } else {
        completion(.success(()))
      }
    }
  }

  func onDisconnectCancel(app: DatabasePigeonFirebaseApp, path: String,
                          completion: @escaping (Result<Void, Error>) -> Void) {
    let database = getDatabaseFromPigeonApp(app)
    let reference = database.reference(withPath: path)

    reference.cancelDisconnectOperations { error, _ in
      if let error {
        completion(.failure(error))
      } else {
        completion(.success(()))
      }
    }
  }

  // MARK: - Query Operations

  func queryObserve(app: DatabasePigeonFirebaseApp, request: QueryRequest,
                    completion: @escaping (Result<String, Error>) -> Void) {
    let database = getDatabaseFromPigeonApp(app)
    let reference = database.reference(withPath: request.path)

    // Apply query modifiers
    var query: DatabaseQuery = reference
    for modifier in request.modifiers {
      if let type = modifier["type"] as? String {
        switch type {
        case "orderByChild":
          if let value = modifier["value"] as? String {
            query = query.queryOrdered(byChild: value)
          }
        case "orderByKey":
          query = query.queryOrderedByKey()
        case "orderByValue":
          query = query.queryOrderedByValue()
        case "orderByPriority":
          query = query.queryOrderedByPriority()
        case "startAt":
          if let value = modifier["value"] {
            query = query.queryStarting(atValue: value)
          }
        case "endAt":
          if let value = modifier["value"] {
            query = query.queryEnding(atValue: value)
          }
        case "equalTo":
          if let value = modifier["value"] {
            query = query.queryEqual(toValue: value)
          }
        case "limitToFirst":
          if let value = modifier["value"] as? NSNumber {
            query = query.queryLimited(toFirst: value.uintValue)
          }
        case "limitToLast":
          if let value = modifier["value"] as? NSNumber {
            query = query.queryLimited(toLast: value.uintValue)
          }
        default:
          break
        }
      }
    }

    // Generate a unique channel name
    listenerCount += 1
    let channelName = "firebase_database_observe_\(listenerCount)"

    let eventChannel = FlutterEventChannel(
      name: channelName,
      binaryMessenger: binaryMessenger
    )

    let streamHandler = FLTFirebaseDatabaseObserveStreamHandler(
      databaseQuery: query,
      disposeBlock: { [weak self] in
        eventChannel.setStreamHandler(nil)
        self?.streamHandlers.removeValue(forKey: channelName)
      }
    )

    eventChannel.setStreamHandler(streamHandler)
    streamHandlers[channelName] = streamHandler

    completion(.success(channelName))
  }

  func queryKeepSynced(app: DatabasePigeonFirebaseApp, request: QueryRequest,
                       completion: @escaping (Result<Void, Error>) -> Void) {
    let database = getDatabaseFromPigeonApp(app)
    let reference = database.reference(withPath: request.path)

    // Apply query modifiers (same logic as queryObserve)
    var query: DatabaseQuery = reference
    for modifier in request.modifiers {
      if let type = modifier["type"] as? String {
        switch type {
        case "orderByChild":
          if let value = modifier["value"] as? String {
            query = query.queryOrdered(byChild: value)
          }
        case "orderByKey":
          query = query.queryOrderedByKey()
        case "orderByValue":
          query = query.queryOrderedByValue()
        case "orderByPriority":
          query = query.queryOrderedByPriority()
        case "startAt":
          if let value = modifier["value"] {
            query = query.queryStarting(atValue: value)
          }
        case "endAt":
          if let value = modifier["value"] {
            query = query.queryEnding(atValue: value)
          }
        case "equalTo":
          if let value = modifier["value"] {
            query = query.queryEqual(toValue: value)
          }
        case "limitToFirst":
          if let value = modifier["value"] as? NSNumber {
            query = query.queryLimited(toFirst: value.uintValue)
          }
        case "limitToLast":
          if let value = modifier["value"] as? NSNumber {
            query = query.queryLimited(toLast: value.uintValue)
          }
        default:
          break
        }
      }
    }

    if let value = request.value {
      query.keepSynced(value)
    }

    completion(.success(()))
  }

  func queryGet(app: DatabasePigeonFirebaseApp, request: QueryRequest,
                completion: @escaping (Result<[String: Any?], Error>) -> Void) {
    let database = getDatabaseFromPigeonApp(app)
    let reference = database.reference(withPath: request.path)

    // Apply query modifiers (same logic as queryObserve)
    var query: DatabaseQuery = reference
    for modifier in request.modifiers {
      if let type = modifier["type"] as? String {
        switch type {
        case "orderByChild":
          if let value = modifier["value"] as? String {
            query = query.queryOrdered(byChild: value)
          }
        case "orderByKey":
          query = query.queryOrderedByKey()
        case "orderByValue":
          query = query.queryOrderedByValue()
        case "orderByPriority":
          query = query.queryOrderedByPriority()
        case "startAt":
          if let value = modifier["value"] {
            query = query.queryStarting(atValue: value)
          }
        case "endAt":
          if let value = modifier["value"] {
            query = query.queryEnding(atValue: value)
          }
        case "equalTo":
          if let value = modifier["value"] {
            query = query.queryEqual(toValue: value)
          }
        case "limitToFirst":
          if let value = modifier["value"] as? NSNumber {
            query = query.queryLimited(toFirst: value.uintValue)
          }
        case "limitToLast":
          if let value = modifier["value"] as? NSNumber {
            query = query.queryLimited(toLast: value.uintValue)
          }
        default:
          break
        }
      }
    }

    query.getData { error, snapshot in
      if let error {
        completion(.failure(error))
      } else if let snapshot {
        let snapshotDict = FLTFirebaseDatabaseUtils.dictionary(from: snapshot)
        completion(.success(["snapshot": snapshotDict]))
      } else {
        completion(.success(["snapshot": NSNull()]))
      }
    }
  }

  // MARK: - Helper Methods

  private func getDatabaseFromPigeonApp(_ app: DatabasePigeonFirebaseApp) -> Database {
    let instanceKey = app.appName + (app.databaseURL ?? "")

    if let cachedInstance = Self.cachedDatabaseInstances[instanceKey] {
      return cachedInstance
    }

    let firebaseApp = FLTFirebasePlugin.firebaseAppNamed(app.appName)!
    let database: Database

    if let databaseURL = app.databaseURL, !databaseURL.isEmpty {
      database = Database.database(app: firebaseApp, url: databaseURL)
    } else {
      database = Database.database(app: firebaseApp)
    }

    // Apply settings
    if let persistenceEnabled = app.settings.persistenceEnabled {
      database.isPersistenceEnabled = persistenceEnabled
    }

    if let cacheSizeBytes = app.settings.cacheSizeBytes {
      database.persistenceCacheSizeBytes = UInt(cacheSizeBytes)
    }

    if let loggingEnabled = app.settings.loggingEnabled {
      Database.setLoggingEnabled(loggingEnabled)
    }

    if let emulatorHost = app.settings.emulatorHost,
       let emulatorPort = app.settings.emulatorPort {
      database.useEmulator(withHost: emulatorHost, port: Int(emulatorPort))
    }

    Self.cachedDatabaseInstances[instanceKey] = database
    return database
  }
}
