// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import FirebaseAuth
import Foundation

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#endif

final class FLTIdTokenChannelStreamHandler: NSObject, FlutterStreamHandler {
  private let auth: Auth
  private var handle: IDTokenDidChangeListenerHandle?

  init(auth: Auth) {
    self.auth = auth
  }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError?
  {
    var initialAuthState = true
    handle = auth.addIDTokenDidChangeListener { auth, user in
      if initialAuthState {
        initialAuthState = false
        return
      }

      if user != nil, let currentUser = auth.currentUser {
        events(["user": PigeonParser.getManualList(PigeonParser.getPigeonDetails(currentUser))])
      } else {
        events(["user": NSNull()])
      }
    }
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    if let handle {
      auth.removeIDTokenDidChangeListener(handle)
    }
    handle = nil
    return nil
  }
}
