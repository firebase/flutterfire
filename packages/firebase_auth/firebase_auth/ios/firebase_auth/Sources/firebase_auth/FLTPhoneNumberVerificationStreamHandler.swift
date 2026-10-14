// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import FirebaseAuth
import Foundation

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#endif

final class FLTPhoneNumberVerificationStreamHandler: NSObject, FlutterStreamHandler {
  private let auth: Auth
  private let phoneNumber: String?
  #if os(iOS)
    private let session: MultiFactorSession?
    private let factorInfo: PhoneMultiFactorInfo?
  #endif

  #if os(iOS)
    init(
      auth: Auth,
      request: InternalVerifyPhoneNumberRequest,
      session: MultiFactorSession?,
      factorInfo: PhoneMultiFactorInfo?
    ) {
      self.auth = auth
      self.phoneNumber = request.phoneNumber
      self.session = session
      self.factorInfo = factorInfo
    }
  #else
    init(auth: Auth, request: InternalVerifyPhoneNumberRequest) {
      self.auth = auth
      self.phoneNumber = request.phoneNumber
    }
  #endif

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError?
  {
    #if os(iOS)
      let completer: (String?, Error?) -> Void = { verificationID, error in
        if let error {
          let errorDetails = AuthErrors.convertToFlutterError(error)
          events([
            "name": "Auth#phoneVerificationFailed",
            "error": [
              "code": errorDetails.code as Any,
              "message": errorDetails.message as Any,
              "details": errorDetails.details as Any,
            ],
          ])
        } else {
          events([
            "name": "Auth#phoneCodeSent",
            "verificationId": verificationID as Any,
          ])
        }
      }

      if let factorInfo {
        PhoneAuthProvider.provider(auth: auth).verifyPhoneNumber(
          with: factorInfo,
          uiDelegate: nil,
          multiFactorSession: session,
          completion: completer
        )
      } else if let phoneNumber {
        PhoneAuthProvider.provider(auth: auth).verifyPhoneNumber(
          phoneNumber,
          uiDelegate: nil,
          multiFactorSession: session,
          completion: completer
        )
      }
    #endif
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    nil
  }
}
