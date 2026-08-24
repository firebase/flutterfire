// Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import FirebaseFirestore
import Foundation

enum PigeonParser {
  static func filterFromJson(_ map: [String: Any]?) -> Filter {
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

  static func parseQuery(parameters: InternalQueryParameters,
                         firestore: Firestore,
                         path: String,
                         isCollectionGroup: Bool) -> Query? {
    do {
      var query: Query
      if isCollectionGroup {
        query = firestore.collectionGroup(path)
      } else {
        query = firestore.collection(path)
      }

      if let filters = parameters.filters as? [String: Any] {
        query = query.whereFilter(filterFromJson(filters))
      }

      if let whereConditions = parameters.where {
        for item in whereConditions {
          guard let condition = item, condition.count >= 3 else { continue }
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
              "FLTFirebaseFirestore: An invalid query operator %@ was received but not handled.",
              op
            )
          }
        }
      }

      if let limit = parameters.limit {
        query = query.limit(to: Int(limit))
      }
      if let limitToLast = parameters.limitToLast {
        query = query.limit(toLast: Int(limitToLast))
      }

      guard let orderBy = parameters.orderBy else {
        return query
      }

      for orderByParameters in orderBy {
        guard let orderByParameters, orderByParameters.count >= 2 else { continue }
        let fieldPath = orderByParameters[0] as! FieldPath
        let descending = orderByParameters[1] as! NSNumber
        query = query.order(by: fieldPath, descending: descending.boolValue)
      }

      if let startAt = parameters.startAt {
        query = query.start(at: startAt as [Any])
      }
      if let startAfter = parameters.startAfter {
        query = query.start(after: startAfter as [Any])
      }
      if let endAt = parameters.endAt {
        query = query.end(at: endAt as [Any])
      }
      if let endBefore = parameters.endBefore {
        query = query.end(before: endBefore as [Any])
      }

      return query
    } catch {
      NSLog(
        "An error occurred while parsing query arguments, this is most likely an error with this SDK."
      )
      return nil
    }
  }

  static func parseSource(_ source: Source) -> FirestoreSource {
    switch source {
    case .serverAndCache:
      return .default
    case .server:
      return .server
    case .cache:
      return .cache
    }
  }

  static func parseFieldPath(_ fieldPaths: [[String?]?]) -> [FieldPath] {
    fieldPaths.compactMap { components in
      guard let components else { return nil }
      return FieldPath(components.compactMap { $0 })
    }
  }

  static func parseServerTimestampBehavior(_ behavior: ServerTimestampBehavior)
    -> FirebaseFirestore.ServerTimestampBehavior {
    switch behavior {
    case .none:
      return .none
    case .estimate:
      return .estimate
    case .previous:
      return .previous
    }
  }

  static func parseListenSource(_ source: ListenSource) -> FirebaseFirestore.ListenSource {
    switch source {
    case .defaultSource:
      return .default
    case .cache:
      return .cache
    }
  }

  static func toPigeonSnapshotMetadata(_ snapshotMetadata: SnapshotMetadata)
    -> InternalSnapshotMetadata {
    InternalSnapshotMetadata(
      hasPendingWrites: snapshotMetadata.hasPendingWrites,
      isFromCache: snapshotMetadata.isFromCache
    )
  }

  static func toPigeonDocumentSnapshot(_ documentSnapshot: DocumentSnapshot,
                                       serverTimestampBehavior: FirebaseFirestore
                                         .ServerTimestampBehavior) -> InternalDocumentSnapshot {
    let data = documentSnapshot.data(with: serverTimestampBehavior)
    let mapped: [String?: Any?]? = data.map { original in
      Dictionary(uniqueKeysWithValues: original.map { ($0.key as String?, $0.value as Any?) })
    }
    return InternalDocumentSnapshot(
      path: documentSnapshot.reference.path,
      data: mapped,
      metadata: toPigeonSnapshotMetadata(documentSnapshot.metadata)
    )
  }

  static func toPigeonDocumentChangeType(_ documentChangeType: DocumentChangeType)
    -> DocumentChangeType {
    documentChangeType
  }

  static func toPigeonDocumentChange(_ documentChange: DocumentChange,
                                     serverTimestampBehavior: FirebaseFirestore
                                       .ServerTimestampBehavior) -> InternalDocumentChange {
    let maxVal = NSNotFound
    let newIndex: Int64
    if documentChange.newIndex == NSNotFound || documentChange.newIndex == 4_294_967_295
      || documentChange.newIndex == maxVal {
      newIndex = -1
    } else {
      newIndex = Int64(documentChange.newIndex)
    }

    let oldIndex: Int64
    if documentChange.oldIndex == NSNotFound || documentChange.oldIndex == 4_294_967_295
      || documentChange.oldIndex == maxVal {
      oldIndex = -1
    } else {
      oldIndex = Int64(documentChange.oldIndex)
    }

    let type: DocumentChangeType
    switch documentChange.type {
    case .added:
      type = .added
    case .modified:
      type = .modified
    case .removed:
      type = .removed
    @unknown default:
      type = .modified
    }

    return InternalDocumentChange(
      type: type,
      document: toPigeonDocumentSnapshot(
        documentChange.document, serverTimestampBehavior: serverTimestampBehavior
      ),
      oldIndex: oldIndex,
      newIndex: newIndex
    )
  }

  static func toPigeonDocumentChanges(_ documentChanges: [DocumentChange],
                                      serverTimestampBehavior: FirebaseFirestore
                                        .ServerTimestampBehavior) -> [
    InternalDocumentChange?
  ] {
    documentChanges.map {
      toPigeonDocumentChange($0, serverTimestampBehavior: serverTimestampBehavior)
    }
  }

  static func toPigeonQuerySnapshot(_ querySnapshot: QuerySnapshot,
                                    serverTimestampBehavior: FirebaseFirestore
                                      .ServerTimestampBehavior) -> InternalQuerySnapshot {
    let documents = querySnapshot.documents.map {
      toPigeonDocumentSnapshot($0, serverTimestampBehavior: serverTimestampBehavior)
        as InternalDocumentSnapshot?
    }
    return InternalQuerySnapshot(
      documents: documents,
      documentChanges: toPigeonDocumentChanges(
        querySnapshot.documentChanges, serverTimestampBehavior: serverTimestampBehavior
      ),
      metadata: toPigeonSnapshotMetadata(querySnapshot.metadata)
    )
  }
}
