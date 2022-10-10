// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import Cocoa
import FlutterMacOS

@NSApplicationMain
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
    
  }
    
  override func application(_ application:NSApplication, open urls: [URL]) {
    var data: [String: URL] = [:]
    data["link"] = urls[0]
    
    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "linkReceived"), object: nil, userInfo: data));
  }
}
