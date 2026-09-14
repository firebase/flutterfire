// Copyright 2025 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import FirebaseAuth
import Foundation

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#endif

enum AuthErrors {
  static func convertToFlutterError(_ error: Error?) -> FlutterError {
    var code = "unknown"
    var message = "An unknown error has occurred."

    guard let error = error as NSError? else {
      return FlutterError(code: code, message: message, details: [:])
    }

    if let firebaseErrorCode = error.userInfo[AuthErrorUserInfoNameKey] as? String {
      code = firebaseErrorCode.replacingOccurrences(of: "ERROR_", with: "")
        .replacingOccurrences(of: "_", with: "-")
        .lowercased()
    }

    if let localized = error.userInfo[NSLocalizedDescriptionKey] as? String {
      message = localized
    }

    var additionalData: [String: Any] = [:]
    if let email = error.userInfo[AuthErrorUserInfoEmailKey] as? String {
      additionalData["email"] = email
    }

    let token = FLTFirebaseAuthPlugin.storeAuthCredentialIfPresent(error)
    if let authCredential = error.userInfo[AuthErrorUserInfoUpdatedCredentialKey] as? AuthCredential
    {
      additionalData["authCredential"] = PigeonParser.getPigeonAuthCredential(
        authCredential, token: token)
    }

    if message == "The password must be 6 characters long or more." {
      message = "Password should be at least 6 characters"
    }

    return FlutterError(code: code, message: message, details: additionalData)
  }

  static func convertAppleAuthorizationErrorToFlutterError(_ error: Error) -> FlutterError {
    let nsError = error as NSError
    var message = "An unknown error has occurred."
    if !nsError.localizedDescription.isEmpty {
      message = nsError.localizedDescription
    }

    var additionalData: [String: Any] = [:]
    let nativeErrorDomain = nsError.domain.isEmpty ? "unknown" : nsError.domain
    additionalData["nativeErrorDomain"] = nativeErrorDomain
    additionalData["nativeErrorCode"] = nsError.code

    var underlyingMessage = ""
    if let underlyingError = nsError.userInfo[NSUnderlyingErrorKey] as? NSError {
      let underlyingErrorDomain =
        underlyingError.domain.isEmpty ? "unknown" : underlyingError.domain
      additionalData["underlyingNativeErrorDomain"] = underlyingErrorDomain
      additionalData["underlyingNativeErrorCode"] = underlyingError.code
      underlyingMessage =
        ", Underlying Domain=\(underlyingErrorDomain) Code=\(underlyingError.code)"
    }

    let detailMessage =
      "\(message) (Domain=\(nativeErrorDomain) Code=\(nsError.code)\(underlyingMessage))"
    return FlutterError(code: "unknown", message: detailMessage, details: additionalData)
  }

  static func noCurrentUser() -> FlutterError {
    FlutterError(code: kErrCodeNoCurrentUser, message: kErrMsgNoCurrentUser, details: nil)
  }

  static func invalidCredential() -> FlutterError {
    FlutterError(
      code: kErrCodeInvalidCredential, message: kErrMsgInvalidCredential, details: nil)
  }
}
