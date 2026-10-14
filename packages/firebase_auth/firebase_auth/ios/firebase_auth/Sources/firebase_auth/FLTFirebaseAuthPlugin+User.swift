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

extension FLTFirebaseAuthPlugin: FirebaseAuthUserHostApi {
  func delete(app: AuthPigeonFirebaseApp, completion: @escaping (Result<Void, Error>) -> Void) {
    guard let currentUser = getFIRAuthFromPigeon(app).currentUser else {
      completion(.failure(AuthErrors.noCurrentUser()))
      return
    }
    currentUser.delete { error in
      self.completeVoid(error, completion: completion)
    }
  }

  func getIdToken(
    app: AuthPigeonFirebaseApp, forceRefresh: Bool,
    completion: @escaping (Result<InternalIdTokenResult, Error>) -> Void
  ) {
    guard let currentUser = getFIRAuthFromPigeon(app).currentUser else {
      completion(.failure(AuthErrors.noCurrentUser()))
      return
    }
    currentUser.getIDTokenResult(forcingRefresh: forceRefresh) { tokenResult, error in
      if let error {
        completion(.failure(AuthErrors.convertToFlutterError(error)))
      } else if let tokenResult {
        completion(.success(PigeonParser.parseIdTokenResult(tokenResult)))
      }
    }
  }

  func linkWithCredential(
    app: AuthPigeonFirebaseApp, input: [String?: Any?],
    completion: @escaping (Result<InternalUserCredential, Error>) -> Void
  ) {
    guard let currentUser = getFIRAuthFromPigeon(app).currentUser else {
      completion(.failure(AuthErrors.noCurrentUser()))
      return
    }
    getFIRAuthCredentialFromArguments(input, app: app) { credential, error in
      if credential == nil {
        completion(.failure(AuthErrors.invalidCredential()))
        return
      }
      if let error {
        completion(.failure(AuthErrors.convertToFlutterError(error)))
      }
      guard let credential else { return }
      currentUser.link(with: credential) { authResult, error in
        self.completeUserCredential(
          app: app, authResult: authResult, error: error, completion: completion)
      }
    }
  }

  func linkWithProvider(
    app: AuthPigeonFirebaseApp, signInProvider: InternalSignInProvider,
    completion: @escaping (Result<InternalUserCredential, Error>) -> Void
  ) {
    let auth = getFIRAuthFromPigeon(app)
    if signInProvider.providerId == kSignInMethodGameCenter {
      completion(
        .failure(
          FlutterError(
            code: "provider-link-failure",
            message: "Game Center provider requires linking with 'linkWithCredential()' API.",
            details: [:])))
      return
    }
    guard let currentUser = auth.currentUser else {
      completion(.failure(AuthErrors.noCurrentUser()))
      return
    }
    if signInProvider.providerId == kSignInMethodApple {
      linkWithAppleUser = currentUser
      launchAppleSignInRequest(app: app, signInProvider: signInProvider, completion: completion)
      return
    }
    #if os(macOS)
      print("linkWithProvider is not supported on the MacOS platform.")
      completion(
        .failure(
          FlutterError(
            code: "unsupported-platform", message: "linkWithProvider is not supported on macOS",
            details: nil)))
    #else
      authProvider = OAuthProvider(providerID: signInProvider.providerId)
      if let scopes = signInProvider.scopes {
        authProvider?.scopes = scopes.compactMap { $0 }
      }
      if let customParameters = signInProvider.customParameters {
        var converted: [String: String] = [:]
        for (key, value) in customParameters {
          if let key, let value { converted[key] = value }
        }
        authProvider?.customParameters = converted
      }
      currentUser.link(with: authProvider!, uiDelegate: nil) { authResult, error in
        self.handleAppleAuthResult(
          app: app, auth: auth, credentials: authResult?.credential, error: error,
          completion: completion)
      }
    #endif
  }

  func reauthenticateWithCredential(
    app: AuthPigeonFirebaseApp, input: [String?: Any?],
    completion: @escaping (Result<InternalUserCredential, Error>) -> Void
  ) {
    guard let currentUser = getFIRAuthFromPigeon(app).currentUser else {
      completion(.failure(AuthErrors.noCurrentUser()))
      return
    }
    getFIRAuthCredentialFromArguments(input, app: app) { credential, error in
      if credential == nil {
        completion(.failure(AuthErrors.invalidCredential()))
        return
      }
      if let error {
        completion(.failure(AuthErrors.convertToFlutterError(error)))
      }
      guard let credential else { return }
      currentUser.reauthenticate(with: credential) { authResult, error in
        self.completeUserCredential(
          app: app, authResult: authResult, error: error, completion: completion)
      }
    }
  }

  func reauthenticateWithProvider(
    app: AuthPigeonFirebaseApp, signInProvider: InternalSignInProvider,
    completion: @escaping (Result<InternalUserCredential, Error>) -> Void
  ) {
    let auth = getFIRAuthFromPigeon(app)
    guard let currentUser = auth.currentUser else {
      completion(.failure(AuthErrors.noCurrentUser()))
      return
    }
    if signInProvider.providerId == kSignInMethodApple {
      isReauthenticatingWithApple = true
      launchAppleSignInRequest(app: app, signInProvider: signInProvider, completion: completion)
      return
    }
    #if os(macOS)
      print("reauthenticateWithProvider is not supported on the MacOS platform.")
      completion(
        .failure(
          FlutterError(
            code: "unsupported-platform",
            message: "reauthenticateWithProvider is not supported on macOS", details: nil)))
    #else
      authProvider = OAuthProvider(providerID: signInProvider.providerId)
      if let scopes = signInProvider.scopes {
        authProvider?.scopes = scopes.compactMap { $0 }
      }
      if let customParameters = signInProvider.customParameters {
        var converted: [String: String] = [:]
        for (key, value) in customParameters {
          if let key, let value { converted[key] = value }
        }
        authProvider?.customParameters = converted
      }
      currentUser.reauthenticate(with: authProvider!, uiDelegate: nil) { authResult, error in
        self.handleAppleAuthResult(
          app: app, auth: auth, credentials: authResult?.credential, error: error,
          completion: completion)
      }
    #endif
  }

  func reload(
    app: AuthPigeonFirebaseApp, completion: @escaping (Result<InternalUserDetails, Error>) -> Void
  ) {
    guard let currentUser = getFIRAuthFromPigeon(app).currentUser else {
      completion(.failure(AuthErrors.noCurrentUser()))
      return
    }
    currentUser.reload { error in
      if let error {
        completion(.failure(AuthErrors.convertToFlutterError(error)))
      } else {
        completion(.success(PigeonParser.getPigeonDetails(currentUser)))
      }
    }
  }

  func sendEmailVerification(
    app: AuthPigeonFirebaseApp, actionCodeSettings: InternalActionCodeSettings?,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    guard let currentUser = getFIRAuthFromPigeon(app).currentUser else {
      completion(.failure(AuthErrors.noCurrentUser()))
      return
    }
    let settings = PigeonParser.parseActionCodeSettings(actionCodeSettings)
    if let settings {
      currentUser.sendEmailVerification(with: settings) { error in
        self.completeVoid(error, completion: completion)
      }
    } else {
      currentUser.sendEmailVerification { error in
        self.completeVoid(error, completion: completion)
      }
    }
  }

  func unlink(
    app: AuthPigeonFirebaseApp, providerId: String,
    completion: @escaping (Result<InternalUserCredential, Error>) -> Void
  ) {
    guard let currentUser = getFIRAuthFromPigeon(app).currentUser else {
      completion(.failure(AuthErrors.noCurrentUser()))
      return
    }
    currentUser.unlink(fromProvider: providerId) { user, error in
      if let error {
        completion(.failure(AuthErrors.convertToFlutterError(error)))
      } else if let user {
        completion(.success(PigeonParser.getPigeonUserCredentialFromFIRUser(user)))
      }
    }
  }

  func updateEmail(
    app: AuthPigeonFirebaseApp, newEmail: String,
    completion: @escaping (Result<InternalUserDetails, Error>) -> Void
  ) {
    guard let currentUser = getFIRAuthFromPigeon(app).currentUser else {
      completion(.failure(AuthErrors.noCurrentUser()))
      return
    }
    currentUser.updateEmail(to: newEmail) { error in
      self.reloadAfterUpdate(user: currentUser, error: error, completion: completion)
    }
  }

  func updatePassword(
    app: AuthPigeonFirebaseApp, newPassword: String,
    completion: @escaping (Result<InternalUserDetails, Error>) -> Void
  ) {
    guard let currentUser = getFIRAuthFromPigeon(app).currentUser else {
      completion(.failure(AuthErrors.noCurrentUser()))
      return
    }
    currentUser.updatePassword(to: newPassword) { error in
      self.reloadAfterUpdate(user: currentUser, error: error, completion: completion)
    }
  }

  func updatePhoneNumber(
    app: AuthPigeonFirebaseApp, input: [String?: Any?],
    completion: @escaping (Result<InternalUserDetails, Error>) -> Void
  ) {
    #if os(iOS)
      guard let currentUser = getFIRAuthFromPigeon(app).currentUser else {
        completion(.failure(AuthErrors.noCurrentUser()))
        return
      }
      getFIRAuthCredentialFromArguments(input, app: app) { credential, error in
        if credential == nil {
          completion(.failure(AuthErrors.invalidCredential()))
          return
        }
        if let error {
          completion(.failure(AuthErrors.convertToFlutterError(error)))
        }
        guard let phoneCredential = credential as? PhoneAuthCredential else { return }
        currentUser.updatePhoneNumber(phoneCredential) { error in
          self.reloadAfterUpdate(user: currentUser, error: error, completion: completion)
        }
      }
    #else
      print(
        "Updating a users phone number via Firebase Authentication is only supported on the iOS platform."
      )
      completion(
        .failure(
          FlutterError(
            code: "unsupported-platform",
            message: "Updating a user's phone number is only supported on iOS", details: nil)))
    #endif
  }

  func updateProfile(
    app: AuthPigeonFirebaseApp, profile: InternalUserProfile,
    completion: @escaping (Result<InternalUserDetails, Error>) -> Void
  ) {
    guard let currentUser = getFIRAuthFromPigeon(app).currentUser else {
      completion(.failure(AuthErrors.noCurrentUser()))
      return
    }
    let changeRequest = currentUser.createProfileChangeRequest()
    if profile.displayNameChanged {
      changeRequest.displayName = profile.displayName
    }
    if profile.photoUrlChanged {
      if let photoUrl = profile.photoUrl {
        changeRequest.photoURL = URL(string: photoUrl)
      } else {
        changeRequest.photoURL = URL(string: "")
      }
    }
    changeRequest.commitChanges { error in
      self.reloadAfterUpdate(user: currentUser, error: error, completion: completion)
    }
  }

  func verifyBeforeUpdateEmail(
    app: AuthPigeonFirebaseApp, newEmail: String,
    actionCodeSettings: InternalActionCodeSettings?,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    guard let currentUser = getFIRAuthFromPigeon(app).currentUser else {
      completion(.failure(AuthErrors.noCurrentUser()))
      return
    }
    if let settings = PigeonParser.parseActionCodeSettings(actionCodeSettings) {
      currentUser.sendEmailVerification(beforeUpdatingEmail: newEmail, actionCodeSettings: settings)
      { error in
        self.completeVoid(error, completion: completion)
      }
    } else {
      currentUser.sendEmailVerification(beforeUpdatingEmail: newEmail) { error in
        self.completeVoid(error, completion: completion)
      }
    }
  }

  func reloadAfterUpdate(
    user: User, error: Error?,
    completion: @escaping (Result<InternalUserDetails, Error>) -> Void
  ) {
    if let error {
      completion(.failure(AuthErrors.convertToFlutterError(error)))
      return
    }
    user.reload { reloadError in
      if let reloadError {
        completion(.failure(AuthErrors.convertToFlutterError(reloadError)))
      } else {
        completion(.success(PigeonParser.getPigeonDetails(user)))
      }
    }
  }
}
