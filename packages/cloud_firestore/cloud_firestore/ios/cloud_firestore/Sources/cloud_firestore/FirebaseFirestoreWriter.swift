// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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

private let kStandardFieldList: UInt8 = 12
private let kStandardFieldMap: UInt8 = 13

class FirebaseFirestoreWriter: FlutterStandardWriter {
  override func writeValue(_ value: Any) {
    if let date = value as? Date {
      writeByte(FirestoreDataType.dateTime.rawValue)
      var ms = Int64(date.timeIntervalSince1970 * 1000.0)
      writeBytes(&ms, length: 8)
    } else if let timestamp = value as? Timestamp {
      var seconds = timestamp.seconds
      var nanoseconds = timestamp.nanoseconds
      writeByte(FirestoreDataType.timestamp.rawValue)
      writeBytes(&seconds, length: 8)
      writeBytes(&nanoseconds, length: 4)
    } else if let geoPoint = value as? GeoPoint {
      var latitude = geoPoint.latitude
      var longitude = geoPoint.longitude
      writeByte(FirestoreDataType.geoPoint.rawValue)
      writeAlignment(8)
      writeBytes(&latitude, length: 8)
      writeBytes(&longitude, length: 8)
    } else if let vector = value as? VectorValue {
      writeByte(FirestoreDataType.vectorValue.rawValue)
      writeValue(vector.array)
    } else if let document = value as? DocumentReference {
      writeByte(FirestoreDataType.documentReference.rawValue)
      writeValue(FLTFirebasePlugin.firebaseAppName(fromIosName: document.firestore.app.name))
      writeValue(document.path)
      let extensionInstance = FirebaseFirestoreUtils.cachedInstance(for: document.firestore)
      writeValue(extensionInstance.databaseURL)
    } else if let snapshot = value as? DocumentSnapshot {
      writeValue(documentSnapshotMap(snapshot))
    } else if let progress = value as? LoadBundleTaskProgress {
      writeValue(loadBundleTaskProgressMap(progress))
    } else if let snapshot = value as? QuerySnapshot {
      writeValue(querySnapshotMap(snapshot))
    } else if let change = value as? DocumentChange {
      writeValue(documentChangeMap(change))
    } else if let metadata = value as? SnapshotMetadata {
      writeValue(snapshotMetadataMap(metadata))
    } else if let list = value as? [Any] {
      writeByte(kStandardFieldList)
      writeSize(UInt32(list.count))
      for item in list {
        writeValue(item)
      }
    } else if let map = value as? [AnyHashable: Any] {
      writeByte(kStandardFieldMap)
      writeSize(UInt32(map.count))
      for (key, item) in map {
        writeValue(key)
        writeValue(item)
      }
    } else if let number = value as? NSNumber {
      if number == NSNumber(value: Double.infinity) {
        writeByte(FirestoreDataType.infinity.rawValue)
        return
      }
      if number == NSNumber(value: -Double.infinity) {
        writeByte(FirestoreDataType.negativeInfinity.rawValue)
        return
      }
      if number.description.lowercased() == "nan" {
        writeByte(FirestoreDataType.nan.rawValue)
        return
      }
      super.writeValue(value)
    } else if let blob = value as? Data {
      writeByte(FirestoreDataType.blob.rawValue)
      writeSize(UInt32(blob.count))
      write(blob)
    } else {
      super.writeValue(value)
    }
  }

  private func snapshotMetadataMap(_ snapshotMetadata: SnapshotMetadata) -> [String: Any] {
    [
      "hasPendingWrites": snapshotMetadata.hasPendingWrites,
      "isFromCache": snapshotMetadata.isFromCache,
    ]
  }

  private func documentChangeMap(_ documentChange: DocumentChange) -> [String: Any] {
    let type: String
    switch documentChange.type {
    case .added:
      type = "DocumentChangeType.added"
    case .modified:
      type = "DocumentChangeType.modified"
    case .removed:
      type = "DocumentChangeType.removed"
    @unknown default:
      type = "DocumentChangeType.modified"
    }

    let maxVal = NSNotFound
    let newIndex: Int
    if documentChange.newIndex == NSNotFound || documentChange.newIndex == 4_294_967_295
      || documentChange.newIndex == maxVal
    {
      newIndex = -1
    } else {
      newIndex = Int(documentChange.newIndex)
    }

    let oldIndex: Int
    if documentChange.oldIndex == NSNotFound || documentChange.oldIndex == 4_294_967_295
      || documentChange.oldIndex == maxVal
    {
      oldIndex = -1
    } else {
      oldIndex = Int(documentChange.oldIndex)
    }

    return [
      "type": type,
      "data": documentChange.document.data(),
      "path": documentChange.document.reference.path,
      "oldIndex": oldIndex,
      "newIndex": newIndex,
      "metadata": documentChange.document.metadata,
    ]
  }

  private func serverTimestampBehavior(from string: String?)
    -> FirebaseFirestore
    .ServerTimestampBehavior
  {
    switch string {
    case "estimate":
      return .estimate
    case "previous":
      return .previous
    default:
      return .none
    }
  }

  private func documentSnapshotMap(_ documentSnapshot: DocumentSnapshot) -> [String: Any]? {
    let hash = NSNumber(value: documentSnapshot.hash)
    let timestampBehaviorString =
      FLTFirebaseFirestorePlugin.serverTimestampMap.object(forKey: hash) as String?
    let behavior = serverTimestampBehavior(from: timestampBehaviorString)
    FLTFirebaseFirestorePlugin.serverTimestampMap.removeObject(forKey: hash)

    let data: Any =
      documentSnapshot.exists
      ? documentSnapshot.data(with: behavior) as Any : NSNull()
    return [
      "path": documentSnapshot.reference.path,
      "data": data,
      "metadata": documentSnapshot.metadata,
    ]
  }

  private func loadBundleTaskProgressMap(_ progress: LoadBundleTaskProgress) -> [String: Any] {
    let state: String
    switch progress.state {
    case .error:
      state = "error"
    case .success:
      state = "success"
    case .inProgress:
      state = "running"
    @unknown default:
      state = "running"
    }
    return [
      "bytesLoaded": progress.bytesLoaded,
      "documentsLoaded": progress.documentsLoaded,
      "totalBytes": progress.totalBytes,
      "totalDocuments": progress.totalDocuments,
      "taskState": state,
    ]
  }

  private func querySnapshotMap(_ querySnapshot: QuerySnapshot) -> [String: Any]? {
    let hash = NSNumber(value: querySnapshot.hash)
    let timestampBehaviorString =
      FLTFirebaseFirestorePlugin.serverTimestampMap.object(forKey: hash) as String?
    let behavior = serverTimestampBehavior(from: timestampBehaviorString)
    FLTFirebaseFirestorePlugin.serverTimestampMap.removeObject(forKey: hash)

    var paths: [String] = []
    var documents: [[String: Any]] = []
    var metadatas: [SnapshotMetadata] = []
    for document in querySnapshot.documents {
      paths.append(document.reference.path)
      documents.append(document.data(with: behavior) ?? [:])
      metadatas.append(document.metadata)
    }

    return [
      "paths": paths,
      "documentChanges": querySnapshot.documentChanges,
      "documents": documents,
      "metadatas": metadatas,
      "metadata": querySnapshot.metadata,
    ]
  }
}
