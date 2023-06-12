#include "firebase_auth_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

#include "firebase/app.h"
#include "firebase/future.h"
#include "firebase/auth.h"
#include "messages.g.h"

#include "firebase_core/firebase_core_plugin_c_api.h"

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <future>
#include <iostream>
#include <memory>
#include <sstream>
#include <stdexcept>
#include <string>

using ::firebase::App;

namespace firebase_auth_windows {

// static
void FirebaseAuthPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto plugin = std::make_unique<FirebaseAuthPlugin>();

  FirebaseAuthHostApi::SetUp(registrar->messenger(), plugin.get());
  FirebaseAuthUserHostApi::SetUp(registrar->messenger(), plugin.get());

  registrar->AddPlugin(std::move(plugin));
}

FirebaseAuthPlugin::FirebaseAuthPlugin() {}

FirebaseAuthPlugin::~FirebaseAuthPlugin() = default;

 firebase::auth::Auth* GetAuthFromPigeon(
    const PigeonFirebaseApp& pigeonApp) {   
  std::shared_ptr<App> app = GetFirebaseApp(pigeonApp.app_name());
  firebase::auth::Auth* auth = firebase::auth::Auth::GetAuth(app.get());

  return auth;
}

 PigeonUserCredential ParseAuthResult(
    const firebase::auth::AuthResult* authResult) {
  PigeonUserCredential result = PigeonUserCredential();
  result.set_user(FirebaseAuthPlugin::ParseUserDetails(authResult->user));
  return result;
}


 PigeonUserDetails FirebaseAuthPlugin::ParseUserDetails(
    const firebase::auth::User user) {
  PigeonUserDetails result = PigeonUserDetails(FirebaseAuthPlugin::ParseUserInfo(&user),
                        FirebaseAuthPlugin::ParseProviderData(&user));

  return result;
 }


  PigeonUserInfo FirebaseAuthPlugin::ParseUserInfo(
     const firebase::auth::User* user) {
  PigeonUserInfo result = PigeonUserInfo(user->uid(), user->is_anonymous(),
                                         user->is_email_verified());
  result.set_display_name(user->display_name());
  result.set_email(user->email());
  result.set_phone_number(user->phone_number());
  result.set_photo_url(user->photo_url());
  result.set_provider_id(user->provider_id());
  result.set_uid(user->uid());

  return result;
}

 flutter::EncodableList FirebaseAuthPlugin::ParseProviderData(
    const firebase::auth::User* user) {

  flutter::EncodableList output;

  for (firebase::auth::UserInfoInterface userInfo : user->provider_data()) {
    output.push_back(FirebaseAuthPlugin::ParseUserInfoToMap(&userInfo));
   
  }

  return flutter::EncodableList(output);
}


 flutter::EncodableValue FirebaseAuthPlugin::ParseUserInfoToMap(
    firebase::auth::UserInfoInterface* userInfo) {
  return flutter::EncodableValue(flutter::EncodableMap{
             {flutter::EncodableValue("displayName"),
              flutter::EncodableValue(userInfo->display_name())},
                               {flutter::EncodableValue("email"),
              flutter::EncodableValue(userInfo->email())},
                               {flutter::EncodableValue("isEmailVerified"),
              flutter::EncodableValue(true)},
                               {flutter::EncodableValue("phoneNumber"),
              flutter::EncodableValue(userInfo->phone_number())},
                               {flutter::EncodableValue("photoUrl"),
              flutter::EncodableValue(userInfo->photo_url())},
                               {flutter::EncodableValue("uid"),
              flutter::EncodableValue(userInfo->uid().empty() ? std::string("") : userInfo->uid())},
                               {flutter::EncodableValue("providerId"),
              flutter::EncodableValue(userInfo->provider_id())},
                               {flutter::EncodableValue("isAnonymous"),
              flutter::EncodableValue(false)}});
}



void FirebaseAuthPlugin::RegisterIdTokenListener(
    const PigeonFirebaseApp &app,
    std::function<void(ErrorOr<std::string> reply)> result) {}

void FirebaseAuthPlugin::RegisterAuthStateListener(
    const PigeonFirebaseApp& app,
    std::function<void(ErrorOr<std::string> reply)> result) {}

void FirebaseAuthPlugin::UseEmulator(
    const PigeonFirebaseApp& app, const std::string& host, int64_t port,
    std::function<void(std::optional<FlutterError> reply)> result) {
  // TODO: function missing???
}

void FirebaseAuthPlugin::ApplyActionCode(
    const PigeonFirebaseApp& app, const std::string& code,
    std::function<void(std::optional<FlutterError> reply)> result) {}

void FirebaseAuthPlugin::CheckActionCode(
    const PigeonFirebaseApp& app, const std::string& code,
    std::function<void(ErrorOr<PigeonActionCodeInfo> reply)> result) {}

void FirebaseAuthPlugin::ConfirmPasswordReset(
    const PigeonFirebaseApp& app, const std::string& code,
    const std::string& new_password,
    std::function<void(std::optional<FlutterError> reply)> result) {}

void FirebaseAuthPlugin::CreateUserWithEmailAndPassword(
    const PigeonFirebaseApp& app, const std::string& email,
    const std::string& password,
    std::function<void(ErrorOr<PigeonUserCredential> reply)> result) {}

void FirebaseAuthPlugin::SignInAnonymously(
    const PigeonFirebaseApp& app,
    std::function<void(ErrorOr<PigeonUserCredential> reply)> result) {
  firebase::auth::Auth* firebaseAuth = GetAuthFromPigeon(app);

  // The SignInAnonymously method returns a Future<User*> in Firebase C++ SDK
  firebase::Future<firebase::auth::AuthResult> signInFuture =
      firebaseAuth->SignInAnonymously();

  signInFuture.OnCompletion(
      [result](const firebase::Future<firebase::auth::AuthResult>&
                   completed_future) {
      std::cout << "Before parsing: " << std::endl;
      
   // We are probably in a different thread right now.
   if (completed_future.error() == 0) {
     PigeonUserCredential credential =
         ParseAuthResult(completed_future.result());
     result(credential);
   }
   else {
     result(FlutterError(completed_future.error_message()));
   }
 });
}

void FirebaseAuthPlugin::SignInWithCredential(
    const PigeonFirebaseApp& app, const flutter::EncodableMap& input,
    std::function<void(ErrorOr<PigeonUserCredential> reply)> result) {}

void FirebaseAuthPlugin::SignInWithCustomToken(
    const PigeonFirebaseApp& app, const std::string& token,
    std::function<void(ErrorOr<PigeonUserCredential> reply)> result) {}

void FirebaseAuthPlugin::SignInWithEmailAndPassword(
    const PigeonFirebaseApp& app, const std::string& email,
    const std::string& password,
    std::function<void(ErrorOr<PigeonUserCredential> reply)> result) {}

void FirebaseAuthPlugin::SignInWithEmailLink(
    const PigeonFirebaseApp& app, const std::string& email,
    const std::string& email_link,
    std::function<void(ErrorOr<PigeonUserCredential> reply)> result) {}

void FirebaseAuthPlugin::SignInWithProvider(
    const PigeonFirebaseApp& app, const PigeonSignInProvider& sign_in_provider,
    std::function<void(ErrorOr<PigeonUserCredential> reply)> result) {}

void FirebaseAuthPlugin::SignOut(
    const PigeonFirebaseApp& app,
    std::function<void(std::optional<FlutterError> reply)> result) {}

void FirebaseAuthPlugin::FetchSignInMethodsForEmail(
    const PigeonFirebaseApp& app, const std::string& email,
    std::function<void(ErrorOr<flutter::EncodableList> reply)> result) {}

void FirebaseAuthPlugin::SendPasswordResetEmail(
    const PigeonFirebaseApp& app, const std::string& email,
    const PigeonActionCodeSettings* action_code_settings,
    std::function<void(std::optional<FlutterError> reply)> result) {}

void FirebaseAuthPlugin::SendSignInLinkToEmail(
    const PigeonFirebaseApp& app, const std::string& email,
    const PigeonActionCodeSettings& action_code_settings,
    std::function<void(std::optional<FlutterError> reply)> result) {}

void FirebaseAuthPlugin::SetLanguageCode(
    const PigeonFirebaseApp& app, const std::string* language_code,
    std::function<void(ErrorOr<std::string> reply)> result) {}

void FirebaseAuthPlugin::SetSettings(
    const PigeonFirebaseApp& app, const PigeonFirebaseAuthSettings& settings,
    std::function<void(std::optional<FlutterError> reply)> result) {}

void FirebaseAuthPlugin::VerifyPasswordResetCode(
    const PigeonFirebaseApp& app, const std::string& code,
    std::function<void(ErrorOr<std::string> reply)> result) {}

void FirebaseAuthPlugin::VerifyPhoneNumber(
    const PigeonFirebaseApp& app, const PigeonVerifyPhoneNumberRequest& request,
    std::function<void(ErrorOr<std::string> reply)> result) {}

void FirebaseAuthPlugin::Delete(
    const PigeonFirebaseApp& app,
    std::function<void(std::optional<FlutterError> reply)> result) {}

void FirebaseAuthPlugin::GetIdToken(
    const PigeonFirebaseApp& app, bool force_refresh,
    std::function<void(ErrorOr<PigeonIdTokenResult> reply)> result) {}

void FirebaseAuthPlugin::LinkWithCredential(
    const PigeonFirebaseApp& app, const flutter::EncodableMap& input,
    std::function<void(ErrorOr<PigeonUserCredential> reply)> result) {}

void FirebaseAuthPlugin::LinkWithProvider(
    const PigeonFirebaseApp& app, const PigeonSignInProvider& sign_in_provider,
    std::function<void(ErrorOr<PigeonUserCredential> reply)> result) {}

void FirebaseAuthPlugin::ReauthenticateWithCredential(
    const PigeonFirebaseApp& app, const flutter::EncodableMap& input,
    std::function<void(ErrorOr<PigeonUserCredential> reply)> result) {}

void FirebaseAuthPlugin::ReauthenticateWithProvider(
    const PigeonFirebaseApp& app, const PigeonSignInProvider& sign_in_provider,
    std::function<void(ErrorOr<PigeonUserCredential> reply)> result) {}

void FirebaseAuthPlugin::Reload(
    const PigeonFirebaseApp& app,
    std::function<void(ErrorOr<PigeonUserDetails> reply)> result) {}

void FirebaseAuthPlugin::SendEmailVerification(
    const PigeonFirebaseApp& app,
    const PigeonActionCodeSettings* action_code_settings,
    std::function<void(std::optional<FlutterError> reply)> result) {}

void FirebaseAuthPlugin::Unlink(
    const PigeonFirebaseApp& app, const std::string& provider_id,
    std::function<void(ErrorOr<PigeonUserCredential> reply)> result) {}

void FirebaseAuthPlugin::UpdateEmail(
    const PigeonFirebaseApp& app, const std::string& new_email,
    std::function<void(ErrorOr<PigeonUserDetails> reply)> result) {}

void FirebaseAuthPlugin::UpdatePassword(
    const PigeonFirebaseApp& app, const std::string& new_password,
    std::function<void(ErrorOr<PigeonUserDetails> reply)> result) {}

void FirebaseAuthPlugin::UpdatePhoneNumber(
    const PigeonFirebaseApp& app, const flutter::EncodableMap& input,
    std::function<void(ErrorOr<PigeonUserDetails> reply)> result) {}

void FirebaseAuthPlugin::UpdateProfile(
    const PigeonFirebaseApp& app, const PigeonUserProfile& profile,
    std::function<void(ErrorOr<PigeonUserDetails> reply)> result) {}

void FirebaseAuthPlugin::VerifyBeforeUpdateEmail(
    const PigeonFirebaseApp& app, const std::string& new_email,
    const PigeonActionCodeSettings* action_code_settings,
    std::function<void(std::optional<FlutterError> reply)> result) {}


}  // namespace firebase_auth
