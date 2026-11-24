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
  private var eventSink: FlutterEventSink?

  init(
    firestore: Firestore,
    reference: DocumentReference,
    includeMetadataChanges: Bool,
    serverTimestampBehavior: FirebaseFirestore.ServerTimestampBehavior,
    source: FirebaseFirestore.ListenSource
  ) {
    self.firestore = firestore
    self.reference = reference
    self.includeMetadataChanges = includeMetadataChanges
    self.serverTimestampBehavior = serverTimestampBehavior
    self.source = source
  }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError?
  {
    let options = SnapshotListenOptions()
      .withIncludeMetadataChanges(includeMetadataChanges)
      .withSource(source)

    eventSink = events
    listenerRegistration = reference.addSnapshotListener(options: options) {
      [weak self] snapshot, error in
      guard let self else {
        return
      }
      if let error {
        let (code, message) = FirebaseFirestoreUtils.errorCodeAndMessage(from: error)
        self.emit(
          FLTFirebasePlugin.createFlutterError(
            fromCode: code,
            message: message,
            optionalDetails: ["code": code, "message": message],
            andOptionalNSError: error as NSError
          )
        )
      } else if let snapshot {
        let serverTimestampBehavior = self.serverTimestampBehavior
        self.emit(
          PigeonParser.toPigeonDocumentSnapshot(
            snapshot, serverTimestampBehavior: serverTimestampBehavior
          )
        )
      }
    }
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    listenerRegistration?.remove()
    listenerRegistration = nil
    return nil
  }

  private func emit(_ event: Any?) {
    DispatchQueue.main.async { [weak self] in
      self?.eventSink?(event)
    }
  }
}
