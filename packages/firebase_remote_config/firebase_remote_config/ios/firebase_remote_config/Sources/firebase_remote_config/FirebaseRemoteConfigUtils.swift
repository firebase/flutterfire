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
         description.contains("403") {
        // See PR for details: https://github.com/firebase/flutterfire/pull/9629
        codeAndMessage["code"] = "forbidden"
        let updateMessage =
          "\(description). You may have to enable the Remote Config API on Google Cloud Platform for your Firebase project."
        codeAndMessage["message"] = updateMessage
      } else {
        codeAndMessage["code"] = "internal"
        codeAndMessage["message"] = error
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
}
