// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import FirebaseCore
import Foundation

/// Fetches the Auth, App Check and FCM tokens through the interop components the SDKs register
/// in the app's component container, as the Functions SDK does. A nil token means the SDK isn't
/// linked or has nothing to give, never failure.
final class InteropTokenProvider {
  private let getComponent: (String) -> AnyObject?

  init(getComponent: @escaping (String) -> AnyObject?) {
    self.getComponent = getComponent
  }

  /// `FirebaseCoreExtension` and the SDKs' interop modules aren't products of the Firebase Swift
  /// package, so this plugin can't import them. It reaches the same Objective-C API by name:
  /// `FIRApp`'s `container` and `-[FIRComponentContainer __instanceForProtocol:]`.
  static func forApp(_ app: FirebaseApp) -> InteropTokenProvider {
    InteropTokenProvider { protocolName in
      // NSProtocolFromString is nil when no linked binary declares the protocol.
      guard let interopProtocol = NSProtocolFromString(protocolName),
        app.responds(to: containerSelector),
        let container = app.perform(containerSelector)?.takeUnretainedValue() as? NSObject,
        container.responds(to: instanceForProtocolSelector)
      else {
        return nil
      }
      return container.perform(instanceForProtocolSelector, with: interopProtocol)?
        .takeUnretainedValue()
    }
  }

  /// The signed-in user's ID token, or nil when Auth isn't linked or nobody is signed in.
  func getAuthIdToken(completion: @escaping (Result<String?, Error>) -> Void) {
    let auth = getComponent(authInteropProtocolName)
    let started: Void? = auth?.interopGetToken?(
      forcingRefresh: false,
      callback: { token, error in
        if let error {
          completion(.failure(error))
        } else {
          // The Auth SDK answers (nil, nil) when nobody is signed in.
          completion(.success(token))
        }
      }
    )
    if started == nil {
      completion(.success(nil))
    }
  }

  /// App Check's answer, or nil when it isn't linked. Before activation the SDK answers with its
  /// placeholder token and an error.
  func getAppCheckToken(
    limitedUse: Bool,
    completion: @escaping (Result<CoreAppCheckInteropToken?, Error>) -> Void
  ) {
    let appCheck = getComponent(appCheckInteropProtocolName)
    let handleResult: (AnyObject) -> Void = { result in
      // A result without `token` means the SDK changed shape; that's a failure, not "not linked".
      guard let token = result.interopToken else {
        completion(
          .failure(
            NSError(
              domain: "FlutterFirebaseCore", code: 0,
              userInfo: [NSLocalizedDescriptionKey: "App Check result has no token"])))
        return
      }
      let error: NSError? = result.interopError ?? nil
      completion(
        .success(
          CoreAppCheckInteropToken(
            token: token,
            error: error?.localizedDescription
          )))
    }
    // `getLimitedUseToken(completion:)` is optional in the protocol.
    let started: Void? =
      limitedUse
      ? appCheck?.interopGetLimitedUseToken?(completion: handleResult)
      : appCheck?.interopGetToken?(forcingRefresh: false, completion: handleResult)
    if started == nil {
      completion(.success(nil))
    }
  }

  /// The cached FCM token, or nil when Messaging isn't linked or has none. Never requests one.
  func getMessagingToken() -> String? {
    let token: String?? = getComponent(messagingInteropProtocolName)?.interopFCMToken
    return token ?? nil
  }
}

// Objective-C runtime names of the interop protocols.
private let authInteropProtocolName = "FIRAuthInterop"
private let appCheckInteropProtocolName = "FIRAppCheckInterop"
private let messagingInteropProtocolName = "FIRMessagingInterop"

private let containerSelector = NSSelectorFromString("container")
private let instanceForProtocolSelector = NSSelectorFromString("__instanceForProtocol:")

// The SDK methods this file calls, redeclared with the selectors from the SDK headers because
// those can't be imported. `AnyObject` lookup skips a call when the object doesn't respond.

/// FIRAuthInterop.h
@objc private protocol AuthInteropMethods {
  @objc(getTokenForcingRefresh:withCallback:)
  func interopGetToken(forcingRefresh: Bool, callback: @escaping (String?, Error?) -> Void)
}

/// FIRAppCheckInterop.h
@objc private protocol AppCheckInteropMethods {
  @objc(getTokenForcingRefresh:completion:)
  func interopGetToken(forcingRefresh: Bool, completion: @escaping (AnyObject) -> Void)

  @objc(getLimitedUseTokenWithCompletion:)
  func interopGetLimitedUseToken(completion: @escaping (AnyObject) -> Void)
}

/// FIRAppCheckTokenResultInterop.h
@objc private protocol AppCheckTokenResultProperties {
  @objc(token) var interopToken: String { get }
  @objc(error) var interopError: NSError? { get }
}

/// FIRMessagingInterop.h
@objc private protocol MessagingInteropProperties {
  @objc(FCMToken) var interopFCMToken: String? { get }
}
