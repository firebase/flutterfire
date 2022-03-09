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
  }

  internal func handleIdChange() {
    var events = [String: String]()
    instance.installationID { (newId: String?, error: Error?) in
      if error != nil {
        self.eventSink!(FlutterError(
          code: "unknown",
          message: error?.localizedDescription,
          details: ["code": "unknown", "message": error?.localizedDescription]
        ))
      } else if newId != self.installationsId {
        self.installationsId = newId!
        events["token"] = self.installationsId
        self.eventSink!(events)
      }
    }
  }

  public func onListen(withArguments _: Any?,
                       eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    eventSink = events
    installationIDObserver = NotificationCenter.default.addObserver(
      forName: .InstallationIDDidChange,
      object: nil,
      queue: nil
    ) { _ in
      self.handleIdChange()
    }
    return nil
  }

  public func onCancel(withArguments _: Any?) -> FlutterError? {
    eventSink = nil
    return nil
  }
}
