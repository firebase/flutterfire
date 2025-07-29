// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#if canImport(FlutterMacOS)
  import FlutterMacOS
#else
  import Flutter
#endif

import FirebaseInstallations
import Foundation

class IdChangedStreamHandler: NSObject, FlutterStreamHandler {
  var eventSink: FlutterEventSink?
  var installationIDObserver: NSObjectProtocol?
  var instance: Installations
  var installationsId: String = ""

  init(instance: Installations) {
    self.instance = instance
    super.init()
  }

  deinit {
    if let observer = installationIDObserver {
      NotificationCenter.default.removeObserver(observer)
    }
  }

  func handleIdChange() {
    instance.installationID { [weak self] (newId: String?, error: Error?) in
      guard let self else { return }

      if let error {
        self.eventSink?(FlutterError(
          code: "unknown",
          message: error.localizedDescription,
          details: ["code": "unknown", "message": error.localizedDescription]
        ))
      } else if let newId, newId != self.installationsId {
        self.installationsId = newId
        self.eventSink?(["token": self.installationsId])
      }
    }
  }

  func onListen(withArguments _: Any?,
                eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    eventSink = events

    installationIDObserver = NotificationCenter.default.addObserver(
      forName: .InstallationIDDidChange,
      object: nil,
      queue: nil
    ) { [weak self] _ in
      self?.handleIdChange()
    }

    // Trigger initial event when listener is added
    handleIdChange()

    return nil
  }

  func onCancel(withArguments _: Any?) -> FlutterError? {
    if let observer = installationIDObserver {
      NotificationCenter.default.removeObserver(observer)
      installationIDObserver = nil
    }
    eventSink = nil
    return nil
  }
}
