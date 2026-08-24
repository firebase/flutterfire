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

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#endif

class FirebaseFirestoreReader: FlutterStandardReader {
  static let firestoreQueue = DispatchQueue(label: "dev.flutter.firebase.firestore")

  override func readValue(ofType type: UInt8) -> Any? {
    switch type {
    case FirestoreDataType.dateTime.rawValue:
      var value: Int64 = 0
      readBytes(&value, length: 8)
      return Date(timeIntervalSince1970: Double(value) / 1000.0)
    case FirestoreDataType.timestamp.rawValue:
      var seconds: Int64 = 0
      var nanoseconds: Int32 = 0
      readBytes(&seconds, length: 8)
      readBytes(&nanoseconds, length: 4)
      return Timestamp(seconds: seconds, nanoseconds: nanoseconds)
    case FirestoreDataType.geoPoint.rawValue:
      var latitude: Double = 0
      var longitude: Double = 0
      readAlignment(8)
      readBytes(&latitude, length: 8)
      readBytes(&longitude, length: 8)
      return GeoPoint(latitude: latitude, longitude: longitude)
    case FirestoreDataType.vectorValue.rawValue:
      return VectorValue((readValue() as? [NSNumber] ?? []).map(\.doubleValue))
    case FirestoreDataType.documentReference.rawValue:
      let firestore = readValue() as! Firestore
      let documentPath = readValue() as! String
      return firestore.document(documentPath)
    case FirestoreDataType.fieldPath.rawValue:
      let length = readSize()
      var array: [Any] = []
      array.reserveCapacity(Int(length))
      for _ in 0..<length {
        let value = readValue()
        array.append(value ?? NSNull())
      }
      return FieldPath(array as! [String])
    case FirestoreDataType.blob.rawValue:
      return readData(UInt(readSize()))
    case FirestoreDataType.arrayUnion.rawValue:
      return FieldValue.arrayUnion(readValue() as? [Any] ?? [])
    case FirestoreDataType.arrayRemove.rawValue:
      return FieldValue.arrayRemove(readValue() as? [Any] ?? [])
    case FirestoreDataType.delete.rawValue:
      return FieldValue.delete()
    case FirestoreDataType.serverTimestamp.rawValue:
      return FieldValue.serverTimestamp()
    case FirestoreDataType.incrementDouble.rawValue:
      return FieldValue.increment((readValue() as! NSNumber).doubleValue)
    case FirestoreDataType.incrementInteger.rawValue:
      return FieldValue.increment(Int64((readValue() as! NSNumber).intValue))
    case FirestoreDataType.documentId.rawValue:
      return FieldPath.documentID()
    case FirestoreDataType.firestoreInstance.rawValue:
      return readFirestore()
    case FirestoreDataType.firestoreQuery.rawValue:
      return readQuery()
    case FirestoreDataType.firestoreSettings.rawValue:
      return readFirestoreSettings()
    case FirestoreDataType.nan.rawValue:
      return Double.nan
    case FirestoreDataType.infinity.rawValue:
      return Double.infinity
    case FirestoreDataType.negativeInfinity.rawValue:
      return -Double.infinity
    default:
      return super.readValue(ofType: type)
    }
  }

  private func readFirestoreSettings() -> FirestoreSettings {
    let values = readValue() as! [String: Any]
    let settings = FirestoreSettings()

    if let persistenceEnabled = values["persistenceEnabled"], !(persistenceEnabled is NSNull) {
      let persistEnabled = (persistenceEnabled as! NSNumber).boolValue
      var size = NSNumber(value: FirestoreCacheSizeUnlimited)
      if let cacheSizeBytes = values["cacheSizeBytes"], !(cacheSizeBytes is NSNull) {
        let cacheSize = cacheSizeBytes as! NSNumber
        if cacheSize.intValue != -1 {
          size = cacheSize
        }
      }
      if persistEnabled {
        settings.cacheSettings = PersistentCacheSettings(sizeBytes: size)
      } else {
        settings.cacheSettings = MemoryCacheSettings(
          garbageCollectorSettings: MemoryLRUGCSettings()
        )
      }
    }

    if let host = values["host"] as? String {
      settings.host = host
      if let sslEnabled = values["sslEnabled"], !(sslEnabled is NSNull) {
        settings.isSSLEnabled = (sslEnabled as! NSNumber).boolValue
      }
    }

    settings.dispatchQueue = FirebaseFirestoreReader.firestoreQueue
    return settings
  }

  private func filterFromJson(_ map: [String: Any]?) -> Filter {
    guard let map else {
      NSException(
        name: NSExceptionName("InvalidOperator"), reason: "Invalid operator", userInfo: nil
      )
      .raise()
      fatalError("Invalid operator")
    }

    if map["fieldPath"] != nil {
      let op = map["op"] as! String
      let fieldPath = map["fieldPath"] as! FieldPath
      let value = map["value"] as Any
      switch op {
      case "==":
        return Filter.whereField(fieldPath, isEqualTo: value)
      case "!=":
        return Filter.whereField(fieldPath, isNotEqualTo: value)
      case "<":
        return Filter.whereField(fieldPath, isLessThan: value)
      case "<=":
        return Filter.whereField(fieldPath, isLessThanOrEqualTo: value)
      case ">":
        return Filter.whereField(fieldPath, isGreaterThan: value)
      case ">=":
        return Filter.whereField(fieldPath, isGreaterOrEqualTo: value)
      case "array-contains":
        return Filter.whereField(fieldPath, arrayContains: value)
      case "array-contains-any":
        return Filter.whereField(fieldPath, arrayContainsAny: value as? [Any] ?? [])
      case "in":
        return Filter.whereField(fieldPath, in: value as? [Any] ?? [])
      case "not-in":
        return Filter.whereField(fieldPath, notIn: value as? [Any] ?? [])
      default:
        NSException(
          name: NSExceptionName("InvalidOperator"), reason: "Invalid operator", userInfo: nil
        )
        .raise()
        fatalError("Invalid operator")
      }
    }

    let op = map["op"] as! String
    let queries = map["queries"] as! [[String: Any]]
    let parsedFilters = queries.map { filterFromJson($0) }

    if op == "OR" {
      return Filter.orFilter(parsedFilters)
    }
    if op == "AND" {
      return Filter.andFilter(parsedFilters)
    }

    NSException(name: NSExceptionName("InvalidOperator"), reason: "Invalid operator", userInfo: nil)
      .raise()
    fatalError("Invalid operator")
  }

  private func readQuery() -> Query? {
    do {
      let values = readValue() as! [String: Any]
      let firestore = values["firestore"] as! Firestore
      let parameters = values["parameters"] as! [String: Any]
      let whereConditions = parameters["where"] as? [Any] ?? []
      let isCollectionGroup = (values["isCollectionGroup"] as! NSNumber).boolValue
      let path = values["path"] as! String

      var query: Query
      if isCollectionGroup {
        query = firestore.collectionGroup(path)
      } else {
        query = firestore.collection(path)
      }

      if let filters = parameters["filters"] as? [String: Any] {
        query = query.whereFilter(filterFromJson(filters))
      }

      for item in whereConditions {
        let condition = item as! [Any]
        let fieldPath = condition[0] as! FieldPath
        let op = condition[1] as! String
        let value = condition[2]
        switch op {
        case "==":
          query = query.whereField(fieldPath, isEqualTo: value as Any)
        case "!=":
          query = query.whereField(fieldPath, isNotEqualTo: value as Any)
        case "<":
          query = query.whereField(fieldPath, isLessThan: value as Any)
        case "<=":
          query = query.whereField(fieldPath, isLessThanOrEqualTo: value as Any)
        case ">":
          query = query.whereField(fieldPath, isGreaterThan: value as Any)
        case ">=":
          query = query.whereField(fieldPath, isGreaterThanOrEqualTo: value as Any)
        case "array-contains":
          query = query.whereField(fieldPath, arrayContains: value as Any)
        case "array-contains-any":
          query = query.whereField(fieldPath, arrayContainsAny: value as? [Any] ?? [])
        case "in":
          query = query.whereField(fieldPath, in: value as? [Any] ?? [])
        case "not-in":
          query = query.whereField(fieldPath, notIn: value as? [Any] ?? [])
        default:
          NSLog(
            "FLTFirebaseFirestore: An invalid query operator %@ was received but not handled.", op
          )
        }
      }

      if let limit = parameters["limit"], !(limit is NSNull) {
        query = query.limit(to: (limit as! NSNumber).intValue)
      }
      if let limitToLast = parameters["limitToLast"], !(limitToLast is NSNull) {
        query = query.limit(toLast: (limitToLast as! NSNumber).intValue)
      }

      let orderBy = parameters["orderBy"]
      if orderBy is NSNull || orderBy == nil {
        return query
      }

      for orderByParameters in orderBy as! [[Any]] {
        let fieldPath = orderByParameters[0] as! FieldPath
        let descending = orderByParameters[1] as! NSNumber
        query = query.order(by: fieldPath, descending: descending.boolValue)
      }

      if let startAt = parameters["startAt"], !(startAt is NSNull) {
        query = query.start(at: startAt as! [Any])
      }
      if let startAfter = parameters["startAfter"], !(startAfter is NSNull) {
        query = query.start(after: startAfter as! [Any])
      }
      if let endAt = parameters["endAt"], !(endAt is NSNull) {
        query = query.end(at: endAt as! [Any])
      }
      if let endBefore = parameters["endBefore"], !(endBefore is NSNull) {
        query = query.end(before: endBefore as! [Any])
      }

      return query
    } catch {
      NSLog(
        "An error occurred while parsing query arguments, this is most likely an error with this SDK. %@"
      )
      return nil
    }
  }

  private func readFirestore() -> Firestore {
    objc_sync_enter(self)
    defer { objc_sync_exit(self) }

    let appNameDart = readValue() as! String
    let databaseUrl = readValue() as! String
    let settings = readValue() as! FirestoreSettings
    let app = FLTFirebasePlugin.firebaseAppNamed(appNameDart)!

    if let cached = FirebaseFirestoreUtils.firestoreInstance(
      appName: app.name, databaseURL: databaseUrl
    ) {
      return cached
    }

    let firestore = Firestore.firestore(app: app, database: databaseUrl)
    firestore.settings = settings
    FirebaseFirestoreUtils.setCachedInstance(
      firestore, appName: app.name, databaseURL: databaseUrl
    )
    return firestore
  }
}
