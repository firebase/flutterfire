// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import FirebaseCore
import FirebaseDatabase
import Foundation

#if canImport(firebase_core)
  import firebase_core
#else
  import firebase_core_shared
#endif

@objc class FLTFirebaseDatabaseUtils: NSObject {
  private static var cachedDatabaseInstances: [String: Database] = [:]

  static func dispatchQueue() -> DispatchQueue {
    enum Static {
      static let sharedInstance = DispatchQueue(
        label: "io.flutter.plugins.firebase.database", qos: .userInitiated
      )
    }
    return Static.sharedInstance
  }

  static func database(from arguments: [String: Any]) -> Database {
    let appName = arguments["appName"] as? String ?? "[DEFAULT]"
    let databaseURL = arguments["databaseURL"] as? String ?? ""
    let instanceKey = appName + databaseURL

    if let cachedInstance = cachedDatabaseInstances[instanceKey] {
      return cachedInstance
    }

    let app = FLTFirebasePlugin.firebaseAppNamed(appName)!
    let database: Database

    if databaseURL.isEmpty {
      database = Database.database(app: app)
    } else {
      database = Database.database(app: app, url: databaseURL)
    }

    if let persistenceEnabled = arguments["persistenceEnabled"] as? Bool {
      database.isPersistenceEnabled = persistenceEnabled
    }

    if let cacheSizeBytes = arguments["cacheSizeBytes"] as? UInt {
      database.persistenceCacheSizeBytes = cacheSizeBytes
    }

    if let loggingEnabled = arguments["loggingEnabled"] as? Bool {
      Database.setLoggingEnabled(loggingEnabled)
    }

    if let emulatorHost = arguments["emulatorHost"] as? String,
       let emulatorPort = arguments["emulatorPort"] as? Int {
      database.useEmulator(withHost: emulatorHost, port: emulatorPort)
    }

    cachedDatabaseInstances[instanceKey] = database
    return database
  }

  static func databaseReference(from arguments: [String: Any]) -> DatabaseReference {
    let database = database(from: arguments)
    let path = arguments["path"] as? String ?? ""
    return database.reference(withPath: path)
  }

  private static func databaseQuery(_ query: DatabaseQuery,
                                    applyLimitModifier modifier: [String: Any]) -> DatabaseQuery {
    let name = modifier["name"] as? String ?? ""
    let limit = modifier["limit"] as? UInt ?? 0

    switch name {
    case "limitToFirst":
      return query.queryLimited(toFirst: limit)
    case "limitToLast":
      return query.queryLimited(toLast: limit)
    default:
      return query
    }
  }

  private static func databaseQuery(_ query: DatabaseQuery,
                                    applyOrderModifier modifier: [String: Any]) -> DatabaseQuery {
    let name = modifier["name"] as? String ?? ""

    switch name {
    case "orderByKey":
      return query.queryOrdered(byChild: "")
    case "orderByValue":
      return query.queryOrdered(byChild: "")
    case "orderByPriority":
      return query.queryOrdered(byChild: "")
    case "orderByChild":
      let path = modifier["path"] as? String ?? ""
      return query.queryOrdered(byChild: path)
    default:
      return query
    }
  }

  private static func databaseQuery(_ query: DatabaseQuery,
                                    applyCursorModifier modifier: [String: Any]) -> DatabaseQuery {
    let name = modifier["name"] as? String ?? ""
    let key = modifier["key"] as? String
    let value = modifier["value"]

    switch name {
    case "startAt":
      if let key {
        return query.queryStarting(atValue: value, childKey: key)
      } else {
        return query.queryStarting(atValue: value)
      }
    case "startAfter":
      if let key {
        return query.queryStarting(afterValue: value, childKey: key)
      } else {
        return query.queryStarting(afterValue: value)
      }
    case "endAt":
      if let key {
        return query.queryEnding(atValue: value, childKey: key)
      } else {
        return query.queryEnding(atValue: value)
      }
    case "endBefore":
      if let key {
        return query.queryEnding(beforeValue: value, childKey: key)
      } else {
        return query.queryEnding(beforeValue: value)
      }
    default:
      return query
    }
  }

  static func databaseQuery(from arguments: [String: Any]) -> DatabaseQuery {
    var query: DatabaseQuery = databaseReference(from: arguments)
    let modifiers = arguments["modifiers"] as? [[String: Any]] ?? []

    for modifier in modifiers {
      let type = modifier["type"] as? String ?? ""

      switch type {
      case "limit":
        query = databaseQuery(query, applyLimitModifier: modifier)
      case "cursor":
        query = databaseQuery(query, applyCursorModifier: modifier)
      case "orderBy":
        query = databaseQuery(query, applyOrderModifier: modifier)
      default:
        break
      }
    }

    return query
  }

  static func dictionary(from snapshot: DataSnapshot,
                         withPreviousChildKey previousChildKey: String?) -> [String: Any] {
    [
      "snapshot": dictionary(from: snapshot),
      "previousChildKey": previousChildKey ?? NSNull(),
    ]
  }

  static func dictionary(from snapshot: DataSnapshot) -> [String: Any] {
    var childKeys: [String] = []

    if snapshot.childrenCount > 0 {
      for child in snapshot.children {
        if let childSnapshot = child as? DataSnapshot {
          childKeys.append(childSnapshot.key ?? "")
        }
      }
    }

    return [
      "key": snapshot.key ?? "",
      "value": snapshot.value ?? NSNull(),
      "priority": snapshot.priority ?? NSNull(),
      "childKeys": childKeys,
    ]
  }

  static func codeAndMessage(from error: Error?) -> [String] {
    var code = "unknown"

    guard let error else {
      return [code, "An unknown error has occurred."]
    }

    let nsError = error as NSError
    var message: String

    switch nsError.code {
    case 1:
      code = "permission-denied"
      message = "Client doesn't have permission to access the desired data."
    case 2:
      code = "unavailable"
      message = "The service is unavailable."
    case 3:
      code = "write-cancelled"
      message = "The write was cancelled by the user."
    case -1:
      code = "data-stale"
      message = "The transaction needs to be run again with current data."
    case -2:
      code = "failure"
      message = "The server indicated that this operation failed."
    case -4:
      code = "disconnected"
      message = "The operation had to be aborted due to a network disconnect."
    case -6:
      code = "expired-token"
      message = "The supplied auth token has expired."
    case -7:
      code = "invalid-token"
      message = "The supplied auth token was invalid."
    case -8:
      code = "max-retries"
      message = "The transaction had too many retries."
    case -9:
      code = "overridden-by-set"
      message = "The transaction was overridden by a subsequent set"
    case -11:
      code = "user-code-exception"
      message = "User code called from the Firebase Database runloop threw an exception."
    case -24:
      code = "network-error"
      message = "The operation could not be performed due to a network error."
    default:
      code = "unknown"
      message = error.localizedDescription
    }
    return [code, message]
  }

  static func eventType(from eventTypeString: String) -> DataEventType {
    switch eventTypeString {
    case "value":
      return .value
    case "childAdded":
      return .childAdded
    case "childChanged":
      return .childChanged
    case "childRemoved":
      return .childRemoved
    case "childMoved":
      return .childMoved
    default:
      return .value
    }
  }
}
