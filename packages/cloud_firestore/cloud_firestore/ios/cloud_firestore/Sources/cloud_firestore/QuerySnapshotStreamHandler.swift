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

final class QuerySnapshotStreamHandler: NSObject, FlutterStreamHandler {
  private let firestore: Firestore
  private let query: Query?
  private let includeMetadataChanges: Bool
  private let serverTimestampBehavior: FirebaseFirestore.ServerTimestampBehavior
  private let source: FirebaseFirestore.ListenSource
  private var listenerRegistration: ListenerRegistration?
  private let snapshotQueue = DispatchQueue(
    label: "io.flutter.plugins.firebase.firestore.query_snapshot"
  )

  init(firestore: Firestore,
       query: Query?,
       includeMetadataChanges: Bool,
       serverTimestampBehavior: FirebaseFirestore.ServerTimestampBehavior,
       source: FirebaseFirestore.ListenSource) {
    self.firestore = firestore
    self.query = query
    self.includeMetadataChanges = includeMetadataChanges
    self.serverTimestampBehavior = serverTimestampBehavior
    self.source = source
  }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError? {
    guard let query else {
      return FlutterError(
        code: "sdk-error",
        message:
        "An error occurred while parsing query arguments, see native logs for more information. Please report this issue.",
        details: nil
      )
    }

    let options = SnapshotListenOptions()
      .withIncludeMetadataChanges(includeMetadataChanges)
      .withSource(source)

    listenerRegistration = query.addSnapshotListener(options: options) { snapshot, error in
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
        self.snapshotQueue.async {
          let pigeonSnapshot = PigeonParser.toPigeonQuerySnapshot(
            snapshot, serverTimestampBehavior: self.serverTimestampBehavior
          )
          DispatchQueue.main.async {
            events(pigeonSnapshot)
          }
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
