// Copyright 2021 The Chromium Authors. All rights reserved.
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

final class DocumentSnapshotStreamHandler: NSObject, FlutterStreamHandler {
  private let firestore: Firestore
  private let reference: DocumentReference
  private let includeMetadataChanges: Bool
  private let serverTimestampBehavior: FirebaseFirestore.ServerTimestampBehavior
  private let source: FirebaseFirestore.ListenSource
  private var listenerRegistration: ListenerRegistration?

  init(firestore: Firestore,
       reference: DocumentReference,
       includeMetadataChanges: Bool,
       serverTimestampBehavior: FirebaseFirestore.ServerTimestampBehavior,
       source: FirebaseFirestore.ListenSource) {
    self.firestore = firestore
    self.reference = reference
    self.includeMetadataChanges = includeMetadataChanges
    self.serverTimestampBehavior = serverTimestampBehavior
    self.source = source
  }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError? {
    let options = SnapshotListenOptions()
      .withIncludeMetadataChanges(includeMetadataChanges)
      .withSource(source)

    listenerRegistration = reference.addSnapshotListener(options: options) { snapshot, error in
      if let error {
        let (code, message) = FirebaseFirestoreUtils.errorCodeAndMessage(from: error)
        DispatchQueue.main.async {
          events(
            FLTFirebasePlugin.createFlutterError(
              fromCode: code,
              message: message,
              optionalDetails: ["code": code, "message": message],
              andOptionalNSError: error as NSError
            )
          )
        }
      } else if let snapshot {
        DispatchQueue.main.async {
          events(
            PigeonParser.toPigeonDocumentSnapshot(
              snapshot, serverTimestampBehavior: self.serverTimestampBehavior
            )
          )
        }
      }
    }
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    listenerRegistration?.remove()
    listenerRegistration = nil
    return nil
  }
}
