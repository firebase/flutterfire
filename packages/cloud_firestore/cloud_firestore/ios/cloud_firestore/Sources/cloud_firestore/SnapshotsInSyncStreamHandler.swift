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
  private var listenerRegistration: ListenerRegistration?

  init(firestore: Firestore) {
    self.firestore = firestore
  }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError?
  {
    listenerRegistration = firestore.addSnapshotsInSyncListener {
      DispatchQueue.main.async {
        events(nil)
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
