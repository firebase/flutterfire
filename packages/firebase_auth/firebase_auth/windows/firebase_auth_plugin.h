#ifndef FLUTTER_PLUGIN_FIREBASE_AUTH_PLUGIN_H_
#define FLUTTER_PLUGIN_FIREBASE_AUTH_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>
#include "firebase/app.h"
#include "firebase/future.h"
#include "firebase/auth.h"
#include "messages.g.h"

#include "messages.g.h"

namespace firebase_auth_windows {

class FirebaseAuthPlugin : public flutter::Plugin,
                           public FirebaseAuthHostApi,
                           public FirebaseAuthUserHostApi {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  FirebaseAuthPlugin();

  virtual ~FirebaseAuthPlugin();

  // Disallow copy and assign.
  FirebaseAuthPlugin(const FirebaseAuthPlugin&) = delete;
  FirebaseAuthPlugin& operator=(const FirebaseAuthPlugin&) = delete;


  // Parser functions
  static PigeonUserDetails ParseUserDetails(const firebase::auth::User user);
  static PigeonUserInfo ParseUserInfo(const firebase::auth::User* user);
  static flutter::EncodableList ParseProviderData(
      const firebase::auth::User* user);
  static flutter::EncodableValue ParseUserInfoToMap(
      firebase::auth::UserInfoInterface* userInfo);

  // FirebaseAuthHostApi methods.
  virtual void RegisterIdTokenListener(
      const PigeonFirebaseApp& app,
      std::function<void(ErrorOr<std::string> reply)> result) override;
  virtual void RegisterAuthStateListener(
      const PigeonFirebaseApp& app,
      std::function<void(ErrorOr<std::string> reply)> result) override;
  virtual void UseEmulator(
      const PigeonFirebaseApp& app, const std::string& host, int64_t port,
      std::function<void(std::optional<FlutterError> reply)> result) override;
  virtual void ApplyActionCode(
      const PigeonFirebaseApp& app, const std::string& code,
      std::function<void(std::optional<FlutterError> reply)> result) override;
  virtual void CheckActionCode(
      const PigeonFirebaseApp& app, const std::string& code,
      std::function<void(ErrorOr<PigeonActionCodeInfo> reply)> result) override;
  virtual void ConfirmPasswordReset(
      const PigeonFirebaseApp& app, const std::string& code,
      const std::string& new_password,
      std::function<void(std::optional<FlutterError> reply)> result) override;
  virtual void CreateUserWithEmailAndPassword(
      const PigeonFirebaseApp& app, const std::string& email,
      const std::string& password,
      std::function<void(ErrorOr<PigeonUserCredential> reply)> result) override;
  virtual void SignInAnonymously(
      const PigeonFirebaseApp& app,
      std::function<void(ErrorOr<PigeonUserCredential> reply)> result) override;
  virtual void SignInWithCredential(
      const PigeonFirebaseApp& app, const flutter::EncodableMap& input,
      std::function<void(ErrorOr<PigeonUserCredential> reply)> result) override;
  virtual void SignInWithCustomToken(
      const PigeonFirebaseApp& app, const std::string& token,
      std::function<void(ErrorOr<PigeonUserCredential> reply)> result) override;
  virtual void SignInWithEmailAndPassword(
      const PigeonFirebaseApp& app, const std::string& email,
      const std::string& password,
      std::function<void(ErrorOr<PigeonUserCredential> reply)> result) override;
  virtual void SignInWithEmailLink(
      const PigeonFirebaseApp& app, const std::string& email,
      const std::string& email_link,
      std::function<void(ErrorOr<PigeonUserCredential> reply)> result) override;
  virtual void SignInWithProvider(
      const PigeonFirebaseApp& app,
      const PigeonSignInProvider& sign_in_provider,
      std::function<void(ErrorOr<PigeonUserCredential> reply)> result) override;
  virtual void SignOut(
      const PigeonFirebaseApp& app,
      std::function<void(std::optional<FlutterError> reply)> result) override;
  virtual void FetchSignInMethodsForEmail(
      const PigeonFirebaseApp& app, const std::string& email,
      std::function<void(ErrorOr<flutter::EncodableList> reply)> result) override;
  virtual void SendPasswordResetEmail(
      const PigeonFirebaseApp& app, const std::string& email,
      const PigeonActionCodeSettings* action_code_settings,
      std::function<void(std::optional<FlutterError> reply)> result) override;
  virtual void SendSignInLinkToEmail(
      const PigeonFirebaseApp& app, const std::string& email,
      const PigeonActionCodeSettings& action_code_settings,
      std::function<void(std::optional<FlutterError> reply)> result) override;
  virtual void SetLanguageCode(
      const PigeonFirebaseApp& app, const std::string* language_code,
      std::function<void(ErrorOr<std::string> reply)> result) override;
  virtual void SetSettings(
      const PigeonFirebaseApp& app, const PigeonFirebaseAuthSettings& settings,
      std::function<void(std::optional<FlutterError> reply)> result) override;
  virtual void VerifyPasswordResetCode(
      const PigeonFirebaseApp& app, const std::string& code,
      std::function<void(ErrorOr<std::string> reply)> result) override;
  virtual void VerifyPhoneNumber(
      const PigeonFirebaseApp& app,
      const PigeonVerifyPhoneNumberRequest& request,
      std::function<void(ErrorOr<std::string> reply)> result) override;

  // FirebaseAuthUserHostApi methods.
  virtual void Delete(
      const PigeonFirebaseApp& app,
      std::function<void(std::optional<FlutterError> reply)> result) override;
  virtual void GetIdToken(
      const PigeonFirebaseApp& app, bool force_refresh,
      std::function<void(ErrorOr<PigeonIdTokenResult> reply)> result) override;
  virtual void LinkWithCredential(
      const PigeonFirebaseApp& app, const flutter::EncodableMap& input,
      std::function<void(ErrorOr<PigeonUserCredential> reply)> result) override;
  virtual void LinkWithProvider(
      const PigeonFirebaseApp& app,
      const PigeonSignInProvider& sign_in_provider,
      std::function<void(ErrorOr<PigeonUserCredential> reply)> result) override;
  virtual void ReauthenticateWithCredential(
      const PigeonFirebaseApp& app, const flutter::EncodableMap& input,
      std::function<void(ErrorOr<PigeonUserCredential> reply)> result) override;
  virtual void ReauthenticateWithProvider(
      const PigeonFirebaseApp& app,
      const PigeonSignInProvider& sign_in_provider,
      std::function<void(ErrorOr<PigeonUserCredential> reply)> result) override;
  virtual void Reload(
      const PigeonFirebaseApp& app,
      std::function<void(ErrorOr<PigeonUserDetails> reply)> result) override;
  virtual void SendEmailVerification(
      const PigeonFirebaseApp& app,
      const PigeonActionCodeSettings* action_code_settings,
      std::function<void(std::optional<FlutterError> reply)> result) override;
  virtual void Unlink(
      const PigeonFirebaseApp& app, const std::string& provider_id,
      std::function<void(ErrorOr<PigeonUserCredential> reply)> result) override;
  virtual void UpdateEmail(
      const PigeonFirebaseApp& app, const std::string& new_email,
      std::function<void(ErrorOr<PigeonUserDetails> reply)> result) override;
  virtual void UpdatePassword(
      const PigeonFirebaseApp& app, const std::string& new_password,
      std::function<void(ErrorOr<PigeonUserDetails> reply)> result) override;
  virtual void UpdatePhoneNumber(
      const PigeonFirebaseApp& app, const flutter::EncodableMap& input,
      std::function<void(ErrorOr<PigeonUserDetails> reply)> result) override;
  virtual void UpdateProfile(
      const PigeonFirebaseApp& app, const PigeonUserProfile& profile,
      std::function<void(ErrorOr<PigeonUserDetails> reply)> result) override;
  virtual void VerifyBeforeUpdateEmail(
      const PigeonFirebaseApp& app, const std::string& new_email,
      const PigeonActionCodeSettings* action_code_settings,
      std::function<void(std::optional<FlutterError> reply)> result) override;
};

}  // namespace firebase_auth_windows

#endif  // FLUTTER_PLUGIN_FIREBASE_AUTH_PLUGIN_H_
