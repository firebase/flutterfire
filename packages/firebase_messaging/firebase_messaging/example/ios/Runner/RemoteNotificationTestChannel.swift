// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import Flutter
import UIKit

/// Test-only channel used by `integration_test/e2e_test.dart`.
///
/// Delivers a remote notification through the app delegate the same way iOS
/// does when a push arrives, without APNs: `simctl push` never calls
/// `application(_:didReceiveRemoteNotification:fetchCompletionHandler:)`.
enum RemoteNotificationTestChannel {
  /// The state `UIApplication.applicationState` reports while a delivery is in
  /// progress. The plugin uses it to choose between `onMessage` and
  /// `onBackgroundMessage`, and a simulator under test is not reliably in the
  /// foreground, so each delivery states the one it simulates.
  fileprivate static var simulatedApplicationState: UIApplication.State?

  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "tests/remote_notifications", binaryMessenger: registrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      guard call.method == "deliver",
        let arguments = call.arguments as? [String: Any],
        let userInfo = arguments["userInfo"] as? [AnyHashable: Any]
      else {
        result(FlutterMethodNotImplemented)
        return
      }
      deliver(
        userInfo, inBackground: arguments["inBackground"] as? Bool ?? false, result: result
      )
    }
  }

  /// Calls the app delegate like iOS does, then reports how many times the
  /// fetch completion handler was called and with which result.
  private static func deliver(
    _ userInfo: [AnyHashable: Any], inBackground: Bool,
    result: @escaping FlutterResult
  ) {
    let application = UIApplication.shared
    let selector = #selector(
      UIApplicationDelegate.application(_:didReceiveRemoteNotification:fetchCompletionHandler:)
    )
    guard let delegate = application.delegate, delegate.responds(to: selector) else {
      result(
        FlutterError(
          code: "not-delivered", message: "The app delegate does not handle remote notifications",
          details: nil
        )
      )
      return
    }

    var completionCount = 0
    var reported = false
    func report(_ fetchResult: UIBackgroundFetchResult?) {
      guard !reported else { return }
      reported = true
      result(["completionCount": completionCount, "fetchResult": fetchResult?.rawValue])
    }

    _ = swizzleApplicationStateOnce
    simulatedApplicationState = inBackground ? .background : .active
    delegate.application?(application, didReceiveRemoteNotification: userInfo) { fetchResult in
      completionCount += 1
      // Leave time for an unexpected second call before reporting.
      DispatchQueue.main.asyncAfter(deadline: .now() + 1) { report(fetchResult) }
    }
    simulatedApplicationState = nil

    // iOS gives the app 30 seconds to call the completion handler.
    DispatchQueue.main.asyncAfter(deadline: .now() + 30) { report(nil) }
  }

  /// Makes `UIApplication.applicationState` report `simulatedApplicationState`
  /// while a delivery is in progress.
  private static let swizzleApplicationStateOnce: Void = {
    guard
      let original = class_getInstanceMethod(
        UIApplication.self, #selector(getter: UIApplication.applicationState)
      ),
      let replacement = class_getInstanceMethod(
        UIApplication.self, #selector(getter: UIApplication.remoteNotificationTestApplicationState)
      )
    else { return }
    method_exchangeImplementations(original, replacement)
  }()
}

extension UIApplication {
  @objc fileprivate dynamic var remoteNotificationTestApplicationState: UIApplication.State {
    if let state = RemoteNotificationTestChannel.simulatedApplicationState {
      return state
    }
    // Implementations are exchanged: this calls the original getter.
    return remoteNotificationTestApplicationState
  }
}
