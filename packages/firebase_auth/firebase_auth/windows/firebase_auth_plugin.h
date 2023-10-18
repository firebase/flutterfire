/*
 * Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

#ifndef FLUTTER_PLUGIN_FIREBASE_AUTH_PLUGIN_H_
#define FLUTTER_PLUGIN_FIREBASE_AUTH_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

#include "firebase/app.h"
#include "firebase/auth.h"
#include "firebase/auth/types.h"
#include "firebase/future.h"
#include "messages.g.h"

using firebase::auth::AuthError;

namespace firebase_auth_windows {

class FirebaseAuthPlugin : public flutter::Plugin,
                           public FirebaseAuthHostApi,
                           public FirebaseAuthUserHostApi {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

  FirebaseAuthPlugin();

  virtual ~FirebaseAuthPlugin();

  // Disallow copy and assign.
  FirebaseAuthPlugin(const FirebaseAuthPlugin&) = delete;
  FirebaseAuthPlugin& operator=(const FirebaseAuthPlugin&) = delete;

  // Parser functions
  static std::string GetAuthErrorCode(AuthError authError);
  static FlutterError ParseError(const firebase::FutureBase& future);

  static PigeonUserDetails ParseUserDetails(const firebase::auth::User user);
  static PigeonAdditionalUserInfo ParseAdditionalUserInfo(
      const firebase::auth::AdditionalUserInfo user);
  static flutter::EncodableMap ConvertToEncodableMap(
      const std::map<firebase::Variant, firebase::Variant>& originalMap);
  static flutter::EncodableValue ConvertToEncodableValue(
      const firebase::Variant& variant);
  static PigeonUserInfo ParseUserInfo(const firebase::auth::User* user);
  static flutter::EncodableList ParseProviderData(
      const firebase::auth::User* user);
  static flutter::EncodableValue ParseUserInfoToMap(
      firebase::auth::UserInfoInterface* userInfo);

  // FirebaseAuthHostApi methods.
  virtual void RegisterIdTokenListener(
      const AuthPigeonFirebaseApp& app,
      std::function<void(ErrorOr<std::string> reply)> result) override;
  virtual void RegisterAuthStateListener(
      const AuthPigeonFirebaseApp& app,
      std::function<void(ErrorOr<std::string> reply)> result) override;
  virtual void UseEmulator(
      const AuthPigeonFirebaseApp& app, const std::string& host, int64_t port,
      std::function<void(std::optional<FlutterError> reply)> result) override;
  virtual void ApplyActionCode(
      const AuthPigeonFirebaseApp& app, const std::string& code,
      std::function<void(std::optional<FlutterError> reply)> result) override;
  virtual void CheckActionCode(
      const AuthPigeonFirebaseApp& app, const std::string& code,
      std::function<void(ErrorOr<PigeonActionCodeInfo> reply)> result) override;
  virtual void ConfirmPasswordReset(
      const AuthPigeonFirebaseApp& app, const std::string& code,
      const std::string& new_password,
      std::function<void(std::optional<FlutterError> reply)> result) override;
  virtual void CreateUserWithEmailAndPassword(
      const AuthPigeonFirebaseApp& app, const std::string& email,
      const std::string& password,
      std::function<void(ErrorOr<PigeonUserCredential> reply)> result) override;
  virtual void SignInAnonymously(
      const AuthPigeonFirebaseApp& app,
      std::function<void(ErrorOr<PigeonUserCredential> reply)> result) override;
  virtual void SignInWithCredential(
      const AuthPigeonFirebaseApp& app, const flutter::EncodableMap& input,
      std::function<void(ErrorOr<PigeonUserCredential> reply)> result) override;
  virtual void SignInWithCustomToken(
      const AuthPigeonFirebaseApp& app, const std::string& token,
      std::function<void(ErrorOr<PigeonUserCredential> reply)> result) override;
  virtual void SignInWithEmailAndPassword(
      const AuthPigeonFirebaseApp& app, const std::string& email,
      const std::string& password,
      std::function<void(ErrorOr<PigeonUserCredential> reply)> result) override;
  virtual void SignInWithEmailLink(
      const AuthPigeonFirebaseApp& app, const std::string& email,
      const std::string& email_link,
      std::function<void(ErrorOr<PigeonUserCredential> reply)> result) override;
  virtual void SignInWithProvider(
      const AuthPigeonFirebaseApp& app,
      const PigeonSignInProvider& sign_in_provider,
      std::function<void(ErrorOr<PigeonUserCredential> reply)> result) override;
  virtual void SignOut(
      const AuthPigeonFirebaseApp& app,
      std::function<void(std::optional<FlutterError> reply)> result) override;
  virtual void FetchSignInMethodsForEmail(
      const AuthPigeonFirebaseApp& app, const std::string& email,
      std::function<void(ErrorOr<flutter::EncodableList> reply)> result)
      override;
  virtual void SendPasswordResetEmail(
      const AuthPigeonFirebaseApp& app, const std::string& email,
      const PigeonActionCodeSettings* action_code_settings,
      std::function<void(std::optional<FlutterError> reply)> result) override;
  virtual void SendSignInLinkToEmail(
      const AuthPigeonFirebaseApp& app, const std::string& email,
      const PigeonActionCodeSettings& action_code_settings,
      std::function<void(std::optional<FlutterError> reply)> result) override;
  virtual void SetLanguageCode(
      const AuthPigeonFirebaseApp& app, const std::string* language_code,
      std::function<void(ErrorOr<std::string> reply)> result) override;
  virtual void SetSettings(
      const AuthPigeonFirebaseApp& app,
      const PigeonFirebaseAuthSettings& settings,
      std::function<void(std::optional<FlutterError> reply)> result) override;
  virtual void VerifyPasswordResetCode(
      const AuthPigeonFirebaseApp& app, const std::string& code,
      std::function<void(ErrorOr<std::string> reply)> result) override;
  virtual void VerifyPhoneNumber(
      const AuthPigeonFirebaseApp& app,
      const PigeonVerifyPhoneNumberRequest& request,
      std::function<void(ErrorOr<std::string> reply)> result) override;

  // FirebaseAuthUserHostApi methods.
  virtual void Delete(
      const AuthPigeonFirebaseApp& app,
      std::function<void(std::optional<FlutterError> reply)> result) override;
  virtual void GetIdToken(
      const AuthPigeonFirebaseApp& app, bool force_refresh,
      std::function<void(ErrorOr<PigeonIdTokenResult> reply)> result) override;
  virtual void LinkWithCredential(
      const AuthPigeonFirebaseApp& app, const flutter::EncodableMap& input,
      std::function<void(ErrorOr<PigeonUserCredential> reply)> result) override;
  virtual void LinkWithProvider(
      const AuthPigeonFirebaseApp& app,
      const PigeonSignInProvider& sign_in_provider,
      std::function<void(ErrorOr<PigeonUserCredential> reply)> result) override;
  virtual void ReauthenticateWithCredential(
      const AuthPigeonFirebaseApp& app, const flutter::EncodableMap& input,
      std::function<void(ErrorOr<PigeonUserCredential> reply)> result) override;
  virtual void ReauthenticateWithProvider(
      const AuthPigeonFirebaseApp& app,
      const PigeonSignInProvider& sign_in_provider,
      std::function<void(ErrorOr<PigeonUserCredential> reply)> result) override;
  virtual void Reload(
      const AuthPigeonFirebaseApp& app,
      std::function<void(ErrorOr<PigeonUserDetails> reply)> result) override;
  virtual void SendEmailVerification(
      const AuthPigeonFirebaseApp& app,
      const PigeonActionCodeSettings* action_code_settings,
      std::function<void(std::optional<FlutterError> reply)> result) override;
  virtual void Unlink(
      const AuthPigeonFirebaseApp& app, const std::string& provider_id,
      std::function<void(ErrorOr<PigeonUserCredential> reply)> result) override;
  virtual void UpdateEmail(
      const AuthPigeonFirebaseApp& app, const std::string& new_email,
      std::function<void(ErrorOr<PigeonUserDetails> reply)> result) override;
  virtual void UpdatePassword(
      const AuthPigeonFirebaseApp& app, const std::string& new_password,
      std::function<void(ErrorOr<PigeonUserDetails> reply)> result) override;
  virtual void UpdatePhoneNumber(
      const AuthPigeonFirebaseApp& app, const flutter::EncodableMap& input,
      std::function<void(ErrorOr<PigeonUserDetails> reply)> result) override;
  virtual void UpdateProfile(
      const AuthPigeonFirebaseApp& app, const PigeonUserProfile& profile,
      std::function<void(ErrorOr<PigeonUserDetails> reply)> result) override;
  virtual void VerifyBeforeUpdateEmail(
      const AuthPigeonFirebaseApp& app, const std::string& new_email,
      const PigeonActionCodeSettings* action_code_settings,
      std::function<void(std::optional<FlutterError> reply)> result) override;

  virtual void RevokeTokenWithAuthorizationCode(
      const AuthPigeonFirebaseApp& app, const std::string& authorization_code,
      std::function<void(std::optional<FlutterError> reply)> result) override;

 private:
  static flutter::BinaryMessenger* binaryMessenger;
};

}  // namespace firebase_auth_windows

#endif  // FLUTTER_PLUGIN_FIREBASE_AUTH_PLUGIN_H_
