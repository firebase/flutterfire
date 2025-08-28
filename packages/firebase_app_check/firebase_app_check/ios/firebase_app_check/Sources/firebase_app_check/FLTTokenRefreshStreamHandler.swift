// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

#if TARGET_OS_OSX
import FlutterMacOS
#else
import Flutter
#endif

private let kNotificationEvent = NSNotification.Name("FIRAppCheckAppCheckTokenDidChangeNotification")
private let kTokenKey = "FIRAppCheckTokenNotificationKey"

class FLTTokenRefreshStreamHandler: NSObject, FlutterStreamHandler {
    private var observer: NSObjectProtocol?
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        observer = NotificationCenter.default.addObserver(
            forName: kNotificationEvent,
            object: nil,
            queue: nil
        ) { notification in
            if let token = notification.userInfo?[kTokenKey] as? String {
                events(["token": token])
            }
        }
        
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
            self.observer = nil
        }
        return nil
    }
} 