// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import FirebaseFirestore
import Foundation

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#endif

final class SnapshotsInSyncStreamHandler: NSObject, FlutterStreamHandler {
  private let firestore: Firestore
  private let snapshotQueue: DispatchQueue
  private var listenerRegistration: ListenerRegistration?
  private var eventSink: FlutterEventSink?

  init(firestore: Firestore, snapshotQueue: DispatchQueue) {
    self.firestore = firestore
    self.snapshotQueue = snapshotQueue
  }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError?
  {
    eventSink = events
    listenerRegistration = firestore.addSnapshotsInSyncListener { [weak self] in
      guard let self else {
        return
      }
      self.snapshotQueue.async { [weak self] in
        self?.emit(nil)
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
