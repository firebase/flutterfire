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

extension FLTFirebaseAuthPlugin: MultiFactorUserHostApi, MultiFactoResolverHostApi,
  MultiFactorTotpHostApi, MultiFactorTotpSecretHostApi
{
  func enrollPhone(
    app: AuthPigeonFirebaseApp, assertion: InternalPhoneMultiFactorAssertion,
    displayName: String?, completion: @escaping (Result<Void, Error>) -> Void
  ) {
    #if os(macOS)
      completion(
        .failure(
          FlutterError(
            code: "unsupported-platform",
            message: "Phone authentication is not supported on macOS", details: nil)))
    #else
      guard let multiFactor = getAppMultiFactorFromPigeon(app) else {
        completion(.failure(AuthErrors.noCurrentUser()))
        return
      }
      let credential = PhoneAuthProvider.provider(auth: getFIRAuthFromPigeon(app)).credential(
        withVerificationID: assertion.verificationId, verificationCode: assertion.verificationCode)
      let multiFactorAssertion = PhoneMultiFactorGenerator.assertion(with: credential)
      multiFactor.enroll(with: multiFactorAssertion, displayName: displayName) { error in
        if let error {
          completion(
            .failure(
              FlutterError(
                code: "enroll-failed", message: error.localizedDescription, details: nil)))
        } else {
          completion(.success(()))
        }
      }
    #endif
  }

  func getEnrolledFactors(
    app: AuthPigeonFirebaseApp,
    completion: @escaping (Result<[InternalMultiFactorInfo], Error>) -> Void
  ) {
    guard let multiFactor = getAppMultiFactorFromPigeon(app) else {
      completion(.failure(AuthErrors.noCurrentUser()))
      return
    }
    let results: [InternalMultiFactorInfo] = multiFactor.enrolledFactors.map { info in
      var phoneNumber: String?
      if let phoneInfo = info as? PhoneMultiFactorInfo {
        phoneNumber = phoneInfo.phoneNumber
      }
      return InternalMultiFactorInfo(
        displayName: info.displayName,
        enrollmentTimestamp: info.enrollmentDate.timeIntervalSince1970,
        factorId: info.factorID,
        uid: info.uid,
        phoneNumber: phoneNumber)
    }
    completion(.success(results))
  }

  func getSession(
    app: AuthPigeonFirebaseApp,
    completion: @escaping (Result<InternalMultiFactorSession, Error>) -> Void
  ) {
    guard let multiFactor = getAppMultiFactorFromPigeon(app) else {
      completion(.failure(AuthErrors.noCurrentUser()))
      return
    }
    multiFactor.getSessionWithCompletion { session, _ in
      let id = UUID().uuidString
      self.multiFactorSessionMap[id] = session
      completion(.success(InternalMultiFactorSession(id: id)))
    }
  }

  func unenroll(
    app: AuthPigeonFirebaseApp, factorUid: String,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    guard let multiFactor = getAppMultiFactorFromPigeon(app) else {
      completion(.failure(AuthErrors.noCurrentUser()))
      return
    }
    multiFactor.unenroll(withFactorUID: factorUid) { error in
      if let error {
        completion(
          .failure(
            FlutterError(
              code: "unenroll-failed", message: error.localizedDescription, details: nil)))
      } else {
        completion(.success(()))
      }
    }
  }

  func enrollTotp(
    app: AuthPigeonFirebaseApp, assertionId: String, displayName: String?,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    guard let multiFactor = getAppMultiFactorFromPigeon(app) else {
      completion(.failure(AuthErrors.noCurrentUser()))
      return
    }
    guard let assertion = multiFactorAssertionMap[assertionId] else {
      completion(
        .failure(
          FlutterError(code: "enroll-failed", message: "Assertion not found", details: nil)))
      return
    }
    multiFactor.enroll(with: assertion, displayName: displayName) { error in
      if let error {
        completion(
          .failure(
            FlutterError(
              code: "enroll-failed", message: error.localizedDescription, details: nil)))
      } else {
        completion(.success(()))
      }
    }
  }

  func resolveSignIn(
    resolverId: String, assertion: InternalPhoneMultiFactorAssertion?, totpAssertionId: String?,
    completion: @escaping (Result<InternalUserCredential, Error>) -> Void
  ) {
    guard let resolver = multiFactorResolverMap[resolverId] else {
      completion(
        .failure(
          FlutterError(
            code: "resolve-signin-failed", message: "Resolver not found", details: nil)))
      return
    }

    var multiFactorAssertion: MultiFactorAssertion?
    if let assertion {
      #if os(iOS)
        let credential = PhoneAuthProvider.provider().credential(
          withVerificationID: assertion.verificationId,
          verificationCode: assertion.verificationCode)
        multiFactorAssertion = PhoneMultiFactorGenerator.assertion(with: credential)
      #endif
    } else if let totpAssertionId {
      multiFactorAssertion = multiFactorAssertionMap[totpAssertionId]
    } else {
      completion(
        .failure(
          FlutterError(
            code: "resolve-signin-failed",
            message: "Neither assertion nor totpAssertionId were provided", details: nil)))
      return
    }

    guard let multiFactorAssertion else {
      completion(
        .failure(
          FlutterError(
            code: "resolve-signin-failed", message: "Assertion could not be created", details: nil)
        ))
      return
    }

    resolver.resolveSignIn(with: multiFactorAssertion) { authResult, error in
      if let error {
        completion(
          .failure(
            FlutterError(
              code: "resolve-signin-failed", message: error.localizedDescription, details: nil)))
      } else if let authResult {
        completion(
          .success(
            PigeonParser.getPigeonUserCredentialFromAuthResult(
              authResult, authorizationCode: nil)))
      }
    }
  }

  func generateSecret(
    sessionId: String, completion: @escaping (Result<InternalTotpSecret, Error>) -> Void
  ) {
    guard let multiFactorSession = multiFactorSessionMap[sessionId] else {
      completion(
        .failure(
          FlutterError(
            code: "generate-secret-failed", message: "Session not found", details: nil)))
      return
    }
    TOTPMultiFactorGenerator.generateSecret(with: multiFactorSession) { secret, error in
      if let error {
        completion(
          .failure(
            FlutterError(
              code: "generate-secret-failed", message: error.localizedDescription, details: nil)))
      } else if let secret {
        self.multiFactorTotpSecretMap[secret.sharedSecretKey()] = secret
        completion(.success(PigeonParser.getPigeonTotpSecret(secret)))
      }
    }
  }

  func getAssertionForEnrollment(
    secretKey: String, oneTimePassword: String,
    completion: @escaping (Result<String, Error>) -> Void
  ) {
    let totpSecret = multiFactorTotpSecretMap[secretKey]
    let assertion = TOTPMultiFactorGenerator.assertionForEnrollment(
      with: totpSecret!, oneTimePassword: oneTimePassword)
    let id = UUID().uuidString
    multiFactorAssertionMap[id] = assertion
    completion(.success(id))
  }

  func getAssertionForSignIn(
    enrollmentId: String, oneTimePassword: String,
    completion: @escaping (Result<String, Error>) -> Void
  ) {
    let assertion = TOTPMultiFactorGenerator.assertionForSignIn(
      withEnrollmentID: enrollmentId, oneTimePassword: oneTimePassword)
    let id = UUID().uuidString
    multiFactorAssertionMap[id] = assertion
    completion(.success(id))
  }

  func generateQrCodeUrl(
    secretKey: String, accountName: String?, issuer: String?,
    completion: @escaping (Result<String, Error>) -> Void
  ) {
    let totpSecret = multiFactorTotpSecretMap[secretKey]
    completion(
      .success(
        totpSecret?.generateQRCodeURL(
          withAccountName: accountName ?? "", issuer: issuer ?? "") ?? ""))
  }

  func openInOtpApp(
    secretKey: String, qrCodeUrl: String, completion: @escaping (Result<Void, Error>) -> Void
  ) {
    multiFactorTotpSecretMap[secretKey]?.openInOTPApp(withQRCodeURL: qrCodeUrl)
    completion(.success(()))
  }
}
