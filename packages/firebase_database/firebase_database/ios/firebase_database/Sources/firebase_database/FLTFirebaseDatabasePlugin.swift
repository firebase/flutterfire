// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import FirebaseCore
import FirebaseDatabase
import Foundation

#if canImport(FlutterMacOS)
  import FlutterMacOS
#else
  import Flutter
#endif

#if canImport(firebase_core)
  import firebase_core
#else
  import firebase_core_shared
#endif
import FirebaseDatabase

// Channel name constant to match macOS implementation
let FLTFirebaseDatabaseChannelName = "plugins.flutter.io/firebase_database"

@objc(FLTFirebaseDatabasePlugin)
public class FLTFirebaseDatabasePlugin: NSObject, FlutterPlugin, FLTFirebasePluginProtocol,
  FirebaseDatabaseHostApi {
  private var binaryMessenger: FlutterBinaryMessenger
  private static var cachedDatabaseInstances: [String: Database] = [:]
  private var streamHandlers: [String: FLTFirebaseDatabaseObserveStreamHandler] = [:]
  private var listenerCount: Int = 0
  private var transactionResults: [Int64: [String: Any?]] = [:]

  private func createFlutterError(_ error: Error) -> PigeonError {
    let parts = FLTFirebaseDatabaseUtils.codeAndMessage(from: error)
    let code = parts[0]
    let message = parts[1]
    let details: [String: Any] = [
      "code": code,
      "message": message,
    ]
    return PigeonError(code: code, message: message, details: details)
  }

  init(messenger: FlutterBinaryMessenger) {
    binaryMessenger = messenger
    super.init()
  }

  @objc public static func register(with registrar: FlutterPluginRegistrar) {
    #if canImport(FlutterMacOS)
      let messenger = registrar.messenger
    #else
      let messenger = registrar.messenger()
    #endif

    let instance = FLTFirebaseDatabasePlugin(
      messenger: messenger
    )

    // Set up Pigeon API using plugin as HostApi
    FirebaseDatabaseHostApiSetup.setUp(
      binaryMessenger: messenger, api: instance
    )

    FLTFirebasePluginRegistry.sharedInstance().register(instance)

    #if !targetEnvironment(macCatalyst)
      registrar.publish(instance)
    #endif
  }

  func cleanup(completion: (() -> Void)? = nil) {
    // No-op cleanup for now
    completion?()
  }

  public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
    cleanup()
  }

  // MARK: - FLTFirebasePlugin

  public func didReinitializeFirebaseCore(_ completion: @escaping () -> Void) {
    cleanup()
    completion()
  }

  public func pluginConstants(for firebaseApp: FirebaseApp) -> [AnyHashable: Any] {
    [:]
  }

  @objc public func firebaseLibraryName() -> String {
    "flutter-fire-rtdb"
  }

  public func firebaseLibraryVersion() -> String {
    versionNumber
  }

  @objc public func flutterChannelName() -> String {
    FLTFirebaseDatabaseChannelName
  }

  // MARK: - Database Management

  func goOnline(app: DatabasePigeonFirebaseApp,
                completion: @escaping (Result<Void, Error>) -> Void) {
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
    let instanceKey = app.appName + (app.databaseURL ?? "")
    if Self.cachedDatabaseInstances[instanceKey] != nil {
      completion(.success(()))
      return
    }

    let database = getDatabaseFromPigeonApp(app)
    database.isPersistenceEnabled = enabled
    completion(.success(()))
  }

  func setPersistenceCacheSizeBytes(app: DatabasePigeonFirebaseApp, cacheSize: Int64,
                                    completion: @escaping (Result<Void, Error>) -> Void) {
    let instanceKey = app.appName + (app.databaseURL ?? "")
    if Self.cachedDatabaseInstances[instanceKey] != nil {
      completion(.success(()))
      return
    }

    let database = getDatabaseFromPigeonApp(app)
    let minCacheSize: UInt = 1 * 1024 * 1024
    let maxCacheSize: UInt = 100 * 1024 * 1024
    let requested = cacheSize > 0 ? UInt(cacheSize) : minCacheSize
    let clamped = max(min(requested, maxCacheSize), minCacheSize)
    database.persistenceCacheSizeBytes = clamped
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
        completion(.failure(self.createFlutterError(error)))
        return
      }

      var snapshotMap: [String: Any?]
      if let snapshot {
        let snapshotDict = FLTFirebaseDatabaseUtils.dictionary(from: snapshot)
        snapshotMap = ["snapshot": snapshotDict]
      } else {
        snapshotMap = ["snapshot": NSNull()]
      }

      self.transactionResults[request.transactionKey] = [
        "committed": committed,
        "snapshot": snapshotMap["snapshot"] as Any,
      ]

      completion(.success(()))
    }
  }

  func databaseReferenceGetTransactionResult(app: DatabasePigeonFirebaseApp, transactionKey: Int64,
                                             completion: @escaping (Result<[String: Any?], Error>)
                                               -> Void) {
    if let result = transactionResults.removeValue(forKey: transactionKey) {
      completion(.success(result))
    } else {
      completion(.success([
        "committed": false,
        "snapshot": ["value": NSNull()],
      ]))
    }
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

    var query: DatabaseQuery = reference
    var hasOrderModifier = false
    for modifier in request.modifiers {
      guard let type = modifier["type"] as? String else { continue }

      switch type {
      case "orderBy":
        if let name = modifier["name"] as? String {
          switch name {
          case "orderByChild":
            if let path = modifier["path"] as? String {
              query = query.queryOrdered(byChild: path)
              hasOrderModifier = true
            }
          case "orderByKey":
            query = query.queryOrderedByKey()
            hasOrderModifier = true
          case "orderByValue":
            query = query.queryOrderedByValue()
            hasOrderModifier = true
          case "orderByPriority":
            query = query.queryOrderedByPriority()
            hasOrderModifier = true
          default:
            break
          }
        }

      case "cursor":
        if let name = modifier["name"] as? String {
          let value = modifier["value"]
          let key = modifier["key"] as? String
          switch name {
          case "startAt":
            if !hasOrderModifier {
              query = query.queryLimited(toFirst: 0)
            } else if let key {
              query = query.queryStarting(atValue: value, childKey: key)
            } else {
              query = query.queryStarting(atValue: value)
            }
          case "startAfter":
            if !hasOrderModifier {
              query = query.queryLimited(toFirst: 0)
            } else if let key {
              query = query.queryStarting(afterValue: value, childKey: key)
            } else {
              query = query.queryStarting(afterValue: value)
            }
          case "endAt":
            if let key {
              query = query.queryEnding(atValue: value, childKey: key)
            } else {
              query = query.queryEnding(atValue: value)
            }
          case "endBefore":
            if let key {
              query = query.queryEnding(beforeValue: value, childKey: key)
            } else {
              query = query.queryEnding(beforeValue: value)
            }
          default:
            break
          }
        }

      case "limit":
        if let name = modifier["name"] as? String,
           let limit = modifier["limit"] as? NSNumber {
          switch name {
          case "limitToFirst":
            query = query.queryLimited(toFirst: limit.uintValue)
          case "limitToLast":
            query = query.queryLimited(toLast: limit.uintValue)
          default:
            break
          }
        }

      default:
        break
      }
    }

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

    var query: DatabaseQuery = reference
    for modifier in request.modifiers {
      guard let type = modifier["type"] as? String else { continue }

      switch type {
      case "orderBy":
        if let name = modifier["name"] as? String {
          switch name {
          case "orderByChild":
            if let path = modifier["path"] as? String {
              query = query.queryOrdered(byChild: path)
            }
          case "orderByKey":
            query = query.queryOrderedByKey()
          case "orderByValue":
            query = query.queryOrderedByValue()
          case "orderByPriority":
            query = query.queryOrderedByPriority()
          default:
            break
          }
        }

      case "cursor":
        if let name = modifier["name"] as? String {
          let value = modifier["value"]
          let key = modifier["key"] as? String
          switch name {
          case "startAt":
            if let key {
              query = query.queryStarting(atValue: value, childKey: key)
            } else {
              query = query.queryStarting(atValue: value)
            }
          case "startAfter":
            if let key {
              query = query.queryStarting(afterValue: value, childKey: key)
            } else {
              query = query.queryStarting(afterValue: value)
            }
          case "endAt":
            if let key {
              query = query.queryEnding(atValue: value, childKey: key)
            } else {
              query = query.queryEnding(atValue: value)
            }
          case "endBefore":
            if let key {
              query = query.queryEnding(beforeValue: value, childKey: key)
            } else {
              query = query.queryEnding(beforeValue: value)
            }
          default:
            break
          }
        }

      case "limit":
        if let name = modifier["name"] as? String,
           let limit = modifier["limit"] as? NSNumber {
          switch name {
          case "limitToFirst":
            query = query.queryLimited(toFirst: limit.uintValue)
          case "limitToLast":
            query = query.queryLimited(toLast: limit.uintValue)
          default:
            break
          }
        }

      default:
        break
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

    var query: DatabaseQuery = reference
    var hasOrderModifier = false
    for modifier in request.modifiers {
      guard let type = modifier["type"] as? String else { continue }

      switch type {
      case "orderBy":
        if let name = modifier["name"] as? String {
          switch name {
          case "orderByChild":
            if let path = modifier["path"] as? String {
              query = query.queryOrdered(byChild: path)
              hasOrderModifier = true
            }
          case "orderByKey":
            query = query.queryOrderedByKey()
            hasOrderModifier = true
          case "orderByValue":
            query = query.queryOrderedByValue()
            hasOrderModifier = true
          case "orderByPriority":
            query = query.queryOrderedByPriority()
            hasOrderModifier = true
          default:
            break
          }
        }

      case "cursor":
        if let name = modifier["name"] as? String {
          let value = modifier["value"]
          let key = modifier["key"] as? String
          switch name {
          case "startAt", "startAfter":
            if !hasOrderModifier {
              completion(.success(["snapshot": NSNull()]))
              return
            }
            if name == "startAt" {
              if let key {
                query = query.queryStarting(atValue: value, childKey: key)
              } else {
                query = query.queryStarting(atValue: value)
              }
            } else {
              if let key {
                query = query.queryStarting(afterValue: value, childKey: key)
              } else {
                query = query.queryStarting(afterValue: value)
              }
            }
          case "endAt":
            if let key {
              query = query.queryEnding(atValue: value, childKey: key)
            } else {
              query = query.queryEnding(atValue: value)
            }
          case "endBefore":
            if let key {
              query = query.queryEnding(beforeValue: value, childKey: key)
            } else {
              query = query.queryEnding(beforeValue: value)
            }
          default:
            break
          }
        }

      case "limit":
        if let name = modifier["name"] as? String,
           let limit = modifier["limit"] as? NSNumber {
          switch name {
          case "limitToFirst":
            query = query.queryLimited(toFirst: limit.uintValue)
          case "limitToLast":
            query = query.queryLimited(toLast: limit.uintValue)
          default:
            break
          }
        }

      default:
        break
      }
    }

    query.getData { error, snapshot in
      if let error {
        completion(.failure(self.createFlutterError(error)))
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

    if let persistenceEnabled = app.settings.persistenceEnabled {
      database.isPersistenceEnabled = persistenceEnabled
    }

    if let cacheSizeBytes = app.settings.cacheSizeBytes {
      let minCacheSize: UInt = 1 * 1024 * 1024
      let maxCacheSize: UInt = 100 * 1024 * 1024
      let requested = cacheSizeBytes > 0 ? UInt(cacheSizeBytes) : minCacheSize
      let clamped = max(min(requested, maxCacheSize), minCacheSize)
      database.persistenceCacheSizeBytes = clamped
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
