// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import FirebaseFirestore
import Foundation

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#endif

enum FirestoreDataType: UInt8 {
  case dateTime = 180
  case geoPoint = 181
  case documentReference = 182
  case blob = 183
  case arrayUnion = 184
  case arrayRemove = 185
  case delete = 186
  case serverTimestamp = 187
  case timestamp = 188
  case incrementDouble = 189
  case incrementInteger = 190
  case documentId = 191
  case fieldPath = 192
  case nan = 193
  case infinity = 194
  case negativeInfinity = 195
  case firestoreInstance = 196
  case firestoreQuery = 197
  case firestoreSettings = 198
  case vectorValue = 199
}

enum FirebaseFirestoreUtils {
  static let pipelineParseErrorCode: Int = -1
  static let errorDomain = "FLTFirebaseFirestore"

  private static let cacheLock = NSLock()
  private static var firestoreInstanceCache: [String: FirebaseFirestoreExtension] = [:]

  private static func key(appName: String, databaseURL: String) -> String {
    "\(appName)|\(databaseURL)"
  }

  static func cachedInstance(appName: String, databaseURL: String) -> FirebaseFirestoreExtension? {
    cacheLock.lock()
    defer { cacheLock.unlock() }
    return firestoreInstanceCache[key(appName: appName, databaseURL: databaseURL)]
  }

  static func setCachedInstance(_ firestore: Firestore, appName: String, databaseURL: String) {
    cacheLock.lock()
    defer { cacheLock.unlock() }
    firestoreInstanceCache[key(appName: appName, databaseURL: databaseURL)] =
      FirebaseFirestoreExtension(firestoreInstance: firestore, databaseURL: databaseURL)
  }

  static func destroyCachedInstance(appName: String, databaseURL: String) {
    cacheLock.lock()
    defer { cacheLock.unlock() }
    firestoreInstanceCache.removeValue(forKey: key(appName: appName, databaseURL: databaseURL))
  }

  static func firestoreInstance(appName: String, databaseURL: String) -> Firestore? {
    cachedInstance(appName: appName, databaseURL: databaseURL)?.instance
  }

  static var count: Int {
    cacheLock.lock()
    defer { cacheLock.unlock() }
    return firestoreInstanceCache.count
  }

  static func cachedInstance(for firestore: Firestore) -> FirebaseFirestoreExtension {
    cacheLock.lock()
    defer { cacheLock.unlock() }
    if let match = firestoreInstanceCache.values.first(where: { $0.instance === firestore }) {
      return match
    }
    NSException(
      name: NSExceptionName("NoCachedInstance"),
      reason: "No cached instance of Firestore",
      userInfo: nil
    ).raise()
    fatalError("No cached instance of Firestore")
  }

  static func cleanupFirestoreInstances(_ completion: (() -> Void)?) {
    cacheLock.lock()
    let entries = Array(firestoreInstanceCache.values)
    cacheLock.unlock()

    let numberOfInstances = entries.count
    if numberOfInstances == 0 {
      completion?()
      return
    }

    var instancesTerminated = 0
    for extensionInstance in entries {
      let firestore = extensionInstance.instance
      DispatchQueue.global(qos: .userInitiated).async {
        firestore.terminate { _ in
          destroyCachedInstance(
            appName: firestore.app.name, databaseURL: extensionInstance.databaseURL
          )
          instancesTerminated += 1
          if instancesTerminated == numberOfInstances {
            completion?()
          }
        }
      }
    }
  }

  static func errorCodeAndMessage(from error: Error?) -> (String, String) {
    var code = "unknown"
    var message = "An unknown error has occurred."

    guard let error = error as NSError? else {
      return (code, message)
    }

    switch error.code {
    case FirestoreErrorCode.aborted.rawValue:
      code = "aborted"
      message =
        "The operation was aborted, typically due to a concurrency issue like transaction aborts, etc."
    case FirestoreErrorCode.alreadyExists.rawValue:
      code = "already-exists"
      message = "Some document that we attempted to create already exists."
    case FirestoreErrorCode.cancelled.rawValue:
      code = "cancelled"
      message = "The operation was cancelled (typically by the caller)."
    case FirestoreErrorCode.dataLoss.rawValue:
      code = "data-loss"
      message = "Unrecoverable data loss or corruption."
    case FirestoreErrorCode.deadlineExceeded.rawValue:
      code = "deadline-exceeded"
      message =
        "Deadline expired before operation could complete. For operations that change the state of the system, this error may be returned even if the operation has completed successfully. For example, a successful response from a server could have been delayed long enough for the deadline to expire."
    case FirestoreErrorCode.failedPrecondition.rawValue:
      code = "failed-precondition"
      if error.localizedDescription.contains("index") {
        message = error.localizedDescription
      } else {
        message =
          "Operation was rejected because the system is not in a state required for the operation's execution. If performing a query, ensure it has been indexed via the Firebase console."
      }
    case FirestoreErrorCode.internal.rawValue:
      code = "internal"
      message =
        "Internal errors. Means some invariants expected by underlying system has been broken. If you see one of these errors, something is very broken."
    case FirestoreErrorCode.invalidArgument.rawValue:
      code = "invalid-argument"
      message =
        "Client specified an invalid argument. Note that this differs from failed-precondition. invalid-argument indicates arguments that are problematic regardless of the state of the system (e.g., an invalid field name)."
    case FirestoreErrorCode.notFound.rawValue:
      code = "not-found"
      message = "Some requested document was not found."
    case FirestoreErrorCode.outOfRange.rawValue:
      code = "out-of-range"
      message = "Operation was attempted past the valid range."
    case FirestoreErrorCode.permissionDenied.rawValue:
      code = "permission-denied"
      message = "The caller does not have permission to execute the specified operation."
    case FirestoreErrorCode.resourceExhausted.rawValue:
      code = "resource-exhausted"
      message =
        "Some resource has been exhausted, perhaps a per-user quota, or perhaps the entire file system is out of space."
    case FirestoreErrorCode.unauthenticated.rawValue:
      code = "unauthenticated"
      message = "The request does not have valid authentication credentials for the operation."
    case FirestoreErrorCode.unavailable.rawValue:
      code = "unavailable"
      message =
        "The service is currently unavailable. This is a most likely a transient condition and may be corrected by retrying with a backoff."
    case FirestoreErrorCode.unimplemented.rawValue:
      code = "unimplemented"
      message = "Operation is not implemented or not supported/enabled."
    case FirestoreErrorCode.unknown.rawValue:
      code = "unknown"
      message = "Unknown error or an error from a different error domain."
    case pipelineParseErrorCode:
      code = "parse-error"
      message =
        error.localizedDescription.isEmpty
          ? "An unknown error occurred." : error.localizedDescription
    default:
      code = "unknown"
      message = "An unknown error occurred."
    }

    if !error.localizedDescription.isEmpty {
      message = error.localizedDescription
    }

    return (code, message)
  }

  static func flutterError(from error: Error) -> FlutterError {
    let (code, message) = errorCodeAndMessage(from: error)
    return FlutterError(
      code: code,
      message: message,
      details: [
        "code": code,
        "message": message,
      ]
    )
  }

  static func parseError(_ message: String) -> NSError {
    NSError(
      domain: errorDomain,
      code: pipelineParseErrorCode,
      userInfo: [NSLocalizedDescriptionKey: message]
    )
  }
}
