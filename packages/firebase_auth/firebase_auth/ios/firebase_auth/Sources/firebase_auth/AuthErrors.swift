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
  // The SDK reports these codes with a generic message that asks to inspect the
  // error details, so the actual reason is appended to the message in the same
  // "[ reason ]" format the Android SDK uses.
  private static let codesWithHiddenDetails: Set<String> = [
    "internal-error",
    "app-verification-failed",
    "keychain-error",
    "web-user-interaction-failure",
  ]
  private static let internalErrorDomain = "FIRAuthInternalErrorDomain"
  private static let unexpectedErrorResponseCode = 3
  private static let deserializedResponseKey = "FIRAuthErrorUserInfoDeserializedResponseKey"
  private static let responseDataKey = "FIRAuthErrorUserInfoDataKey"
  private static let maxDetailLength = 1000

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

    if codesWithHiddenDetails.contains(code), let detail = hiddenErrorDetail(error) {
      message = "\(message) [ \(detail) ]"
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

  private static func hiddenErrorDetail(_ error: NSError) -> String? {
    if let reason = error.userInfo[NSLocalizedFailureReasonErrorKey] as? String, !reason.isEmpty {
      return String(reason.prefix(maxDetailLength))
    }

    guard let underlyingError = error.userInfo[NSUnderlyingErrorKey] as? NSError else {
      return nil
    }

    // Only error responses are surfaced: a successful response the SDK could not
    // parse can contain tokens or profile data.
    if underlyingError.domain == internalErrorDomain,
      underlyingError.code == unexpectedErrorResponseCode
    {
      if let response = underlyingError.userInfo[deserializedResponseKey] as? [String: Any] {
        if let message = response["message"] as? String, !message.isEmpty {
          return String(message.prefix(maxDetailLength))
        }
        if JSONSerialization.isValidJSONObject(response),
          let data = try? JSONSerialization.data(withJSONObject: response),
          let json = String(data: data, encoding: .utf8)
        {
          return String(json.prefix(maxDetailLength))
        }
      }
      if let data = underlyingError.userInfo[responseDataKey] as? Data,
        let body = String(data: data, encoding: .utf8), !body.isEmpty
      {
        return String(body.prefix(maxDetailLength))
      }
    }

    var detail = "Domain=\(underlyingError.domain) Code=\(underlyingError.code)"
    if let rootError = underlyingError.userInfo[NSUnderlyingErrorKey] as? NSError {
      detail += ", Underlying Domain=\(rootError.domain) Code=\(rootError.code)"
    }
    return detail
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
