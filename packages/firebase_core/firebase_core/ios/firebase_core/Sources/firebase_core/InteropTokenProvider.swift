// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import FirebaseCore
import Foundation

/// Fetches the Auth, App Check and FCM tokens from whichever SDKs the app links, the way the
/// Firebase Functions SDK's `FunctionsContextProvider` does.
///
/// Each SDK registers an interop component in its app's component container when it is linked.
/// `getComponent` looks a component up by the name of its Objective-C protocol and returns nil
/// when no linked SDK registered it, so a nil token means "not linked" or "nothing to give", never
/// failure.
final class InteropTokenProvider {
  private let getComponent: (String) -> AnyObject?

  init(getComponent: @escaping (String) -> AnyObject?) {
    self.getComponent = getComponent
  }

  /// Looks tokens up in the component container of `app`.
  ///
  /// The container and the interop protocols are declared in `FirebaseCoreExtension` and the SDKs'
  /// interop modules, which are not products of the Firebase Swift package, so this plugin can't
  /// import them. It reaches the same Objective-C API by name instead: `FIRApp`'s `container`
  /// property and `-[FIRComponentContainer __instanceForProtocol:]`, which is what
  /// `ComponentType<T>.instance(for:in:)` calls.
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

  /// The signed-in user's ID token, or nil when the Auth SDK isn't linked or nobody is signed in.
  /// Fails with the Auth SDK's error when it can't produce a token.
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

  /// The App Check SDK's answer, or nil when App Check isn't linked. When the SDK can't produce a
  /// token, for example before it is activated, the answer carries its placeholder token and the
  /// reason, as the SDK reports it.
  func getAppCheckToken(
    limitedUse: Bool,
    completion: @escaping (Result<CoreAppCheckInteropToken?, Error>) -> Void
  ) {
    let appCheck = getComponent(appCheckInteropProtocolName)
    let handleResult: (AnyObject) -> Void = { result in
      guard let token = result.interopToken else {
        completion(.success(nil))
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
    // `getLimitedUseToken(completion:)` is optional in the protocol; an SDK without it has no
    // limited-use token to give, as in the Functions SDK.
    let started: Void? =
      limitedUse
      ? appCheck?.interopGetLimitedUseToken?(completion: handleResult)
      : appCheck?.interopGetToken?(forcingRefresh: false, completion: handleResult)
    if started == nil {
      completion(.success(nil))
    }
  }

  /// The FCM registration token the Messaging SDK has cached, or nil when Messaging isn't linked
  /// or has no token yet. Like the Functions SDK, this never asks for a new token.
  func getMessagingToken() -> String? {
    let token: String?? = getComponent(messagingInteropProtocolName)?.interopFCMToken
    return token ?? nil
  }
}

// The Objective-C runtime names of the interop protocols (Swift sees them as `AuthInterop`,
// `AppCheckInterop` and `MessagingInterop`).
private let authInteropProtocolName = "FIRAuthInterop"
private let appCheckInteropProtocolName = "FIRAppCheckInterop"
private let messagingInteropProtocolName = "FIRMessagingInterop"

private let containerSelector = NSSelectorFromString("container")
private let instanceForProtocolSelector = NSSelectorFromString("__instanceForProtocol:")

// The SDK methods this file calls, declared here because their headers can't be imported (see
// `InteropTokenProvider.forApp`). The selectors match the SDK headers named below. The SDKs'
// objects don't conform to these protocols: Swift's `AnyObject` lookup sends the selectors to them
// directly and skips the call when an object doesn't respond.

/// `FIRAuthInterop`, in FirebaseAuth/Interop/Public/FirebaseAuthInterop/FIRAuthInterop.h.
@objc private protocol AuthInteropMethods {
  @objc(getTokenForcingRefresh:withCallback:)
  func interopGetToken(forcingRefresh: Bool, callback: @escaping (String?, Error?) -> Void)
}

/// `FIRAppCheckInterop`, in FirebaseAppCheck/Interop/Public/FirebaseAppCheckInterop/
/// FIRAppCheckInterop.h.
@objc private protocol AppCheckInteropMethods {
  @objc(getTokenForcingRefresh:completion:)
  func interopGetToken(forcingRefresh: Bool, completion: @escaping (AnyObject) -> Void)

  @objc(getLimitedUseTokenWithCompletion:)
  func interopGetLimitedUseToken(completion: @escaping (AnyObject) -> Void)
}

/// `FIRAppCheckTokenResultInterop`, in the same directory.
@objc private protocol AppCheckTokenResultProperties {
  @objc(token) var interopToken: String { get }
  @objc(error) var interopError: NSError? { get }
}

/// `FIRMessagingInterop`, in FirebaseMessaging/Interop/FIRMessagingInterop.h.
@objc private protocol MessagingInteropProperties {
  @objc(FCMToken) var interopFCMToken: String? { get }
}
