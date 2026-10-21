// Copyright 2025 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import FirebaseRemoteConfig

class FLTFirebaseRemoteConfigUtils {
  static func errorCodeAndMessage(from error: NSError) -> [String: String] {
    var codeAndMessage: [String: String] = [:]

    switch error.code {
    case RemoteConfigError.internalError.rawValue:
      if let description = error.userInfo[NSLocalizedDescriptionKey] as? String,
        description.contains("403")
      {
        // See PR for details: https://github.com/firebase/flutterfire/pull/9629
        codeAndMessage["code"] = "forbidden"
        let updateMessage =
          "\(description). You may have to enable the Remote Config API on Google Cloud Platform for your Firebase project."
        codeAndMessage["message"] = updateMessage
      } else {
        codeAndMessage["code"] = "internal"
        codeAndMessage["message"] =
          error
          .userInfo[NSLocalizedDescriptionKey] as? String ?? "Internal error"
      }

    case RemoteConfigError.throttled.rawValue:
      codeAndMessage["code"] = "throttled"
      codeAndMessage["message"] = "frequency of requests exceeds throttled limits"

    default:
      codeAndMessage["code"] = "unknown"
      codeAndMessage["message"] = "unknown remote config error"
    }

    return codeAndMessage
  }

  /// The code and message Dart reports a realtime update error with, the same as on Android.
  ///
  /// Update errors have their own domain, whose codes overlap with `RemoteConfigError`:
  /// `notFetched` and `throttled` are both 8002, so the domain must be checked first.
  static func configUpdateErrorCodeAndMessage(from error: NSError) -> [String: String] {
    // A failed fetch of an announced update is reported with the fetch error itself.
    if error.domain == RemoteConfigErrorDomain {
      return errorCodeAndMessage(from: error)
    }

    var code = "unknown"
    if error.domain == RemoteConfigUpdateErrorDomain {
      switch error.code {
      case RemoteConfigUpdateError.streamError.rawValue:
        code = "config-update-stream-error"
      case RemoteConfigUpdateError.messageInvalid.rawValue:
        code = "config-update-message-invalid"
      case RemoteConfigUpdateError.notFetched.rawValue:
        code = "config-update-not-fetched"
      case RemoteConfigUpdateError.unavailable.rawValue:
        code = "config-update-unavailable"
      default:
        break
      }
    }

    return ["code": code, "message": error.localizedDescription]
  }
}
