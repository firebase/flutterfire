// Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "firebase_auth_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

#include <chrono>
#include <thread>

#include "firebase/app.h"
#include "firebase/auth.h"
#include "firebase/future.h"
#include "firebase/log.h"
#include "firebase/util.h"
#include "firebase/variant.h"
#include "firebase_auth/plugin_version.h"
#include "firebase_core/firebase_core_plugin_c_api.h"
#include "messages.g.h"

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>
#include <flutter/event_channel.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <future>
#include <iostream>
#include <memory>
#include <optional>
#include <sstream>
#include <stdexcept>
#include <string>
#include <string_view>
#include <unordered_map>

using ::firebase::App;
using ::firebase::auth::Auth;

namespace firebase_auth_windows {

static std::string kLibraryName = "flutter-fire-auth";
flutter::BinaryMessenger* FirebaseAuthPlugin::binaryMessenger = nullptr;

// static
void FirebaseAuthPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows* registrar) {
  auto plugin = std::make_unique<FirebaseAuthPlugin>();

  FirebaseAuthHostApi::SetUp(registrar->messenger(), plugin.get());
  FirebaseAuthUserHostApi::SetUp(registrar->messenger(), plugin.get());

  registrar->AddPlugin(std::move(plugin));

  binaryMessenger = registrar->messenger();

  // Register for platform logging
  App::RegisterLibrary(kLibraryName.c_str(), getPluginVersion().c_str(),
                       nullptr);
}

FirebaseAuthPlugin::FirebaseAuthPlugin() {
  firebase::SetLogLevel(firebase::kLogLevelVerbose);
}

FirebaseAuthPlugin::~FirebaseAuthPlugin() = default;

Auth* GetAuthFromPigeon(const AuthPigeonFirebaseApp& pigeonApp) {
  App* app = App::GetInstance(pigeonApp.app_name().c_str());

  Auth* auth = Auth::GetAuth(app);

  return auth;
}

PigeonUserCredential ParseAuthResult(
    const firebase::auth::AuthResult* authResult) {
  PigeonUserCredential result = PigeonUserCredential();
  result.set_user(FirebaseAuthPlugin::ParseUserDetails(authResult->user));
  result.set_additional_user_info(FirebaseAuthPlugin::ParseAdditionalUserInfo(
      authResult->additional_user_info));
  return result;
}

using flutter::EncodableMap;
using flutter::EncodableValue;

flutter::EncodableMap
firebase_auth_windows::FirebaseAuthPlugin::ConvertToEncodableMap(
    const std::map<firebase::Variant, firebase::Variant>& originalMap) {
  EncodableMap convertedMap;
  for (const auto& kv : originalMap) {
    EncodableValue key = ConvertToEncodableValue(
        kv.first);  // convert std::string to EncodableValue
    EncodableValue value = ConvertToEncodableValue(
        kv.second);             // convert FieldValue to EncodableValue
    convertedMap[key] = value;  // insert into the new map
  }
  return convertedMap;
}

flutter::EncodableValue
firebase_auth_windows::FirebaseAuthPlugin::ConvertToEncodableValue(
    const firebase::Variant& variant) {
  switch (variant.type()) {
    case firebase::Variant::kTypeNull:
      return EncodableValue();
    case firebase::Variant::kTypeInt64:
      return EncodableValue(variant.int64_value());
    case firebase::Variant::kTypeDouble:
      return EncodableValue(variant.double_value());
    case firebase::Variant::kTypeBool:
      return EncodableValue(variant.bool_value());
    case firebase::Variant::kTypeStaticString:
      return EncodableValue(variant.string_value());
    case firebase::Variant::kTypeMutableString:
      return EncodableValue(variant.mutable_string());
    case firebase::Variant::kTypeMap:
      return FirebaseAuthPlugin::ConvertToEncodableMap(variant.map());
    case firebase::Variant::kTypeStaticBlob:
      return EncodableValue(flutter::CustomEncodableValue(variant.blob_data()));
    case firebase::Variant::kTypeMutableBlob:
      return EncodableValue(
          flutter::CustomEncodableValue(variant.mutable_blob_data()));
    default:
      return EncodableValue();
  }
}

PigeonAdditionalUserInfo FirebaseAuthPlugin::ParseAdditionalUserInfo(
    const firebase::auth::AdditionalUserInfo additionalUserInfo) {
  // Cannot know if the user is new or not with current API
  PigeonAdditionalUserInfo result = PigeonAdditionalUserInfo(false);
  result.set_profile(ConvertToEncodableMap(additionalUserInfo.profile));
  result.set_provider_id(additionalUserInfo.provider_id);
  result.set_username(additionalUserInfo.user_name);
  return result;
}

PigeonUserDetails FirebaseAuthPlugin::ParseUserDetails(
    const firebase::auth::User user) {
  PigeonUserDetails result =
      PigeonUserDetails(FirebaseAuthPlugin::ParseUserInfo(&user),
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
  result.set_creation_timestamp(user->metadata().creation_timestamp);
  result.set_last_sign_in_timestamp(user->metadata().last_sign_in_timestamp);

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
       flutter::EncodableValue(userInfo->uid().empty() ? std::string("")
                                                       : userInfo->uid())},
      {flutter::EncodableValue("providerId"),
       flutter::EncodableValue(userInfo->provider_id())},
      {flutter::EncodableValue("isAnonymous"),
       flutter::EncodableValue(false)}});
}

std::string FirebaseAuthPlugin::GetAuthErrorCode(AuthError authError) {
  switch (authError) {
    case firebase::auth::kAuthErrorInvalidCustomToken:
      return "invalid-custom-token";
    case firebase::auth::kAuthErrorCustomTokenMismatch:
      return "custom-token-mismatch";
    case firebase::auth::kAuthErrorInvalidEmail:
      return "invalid-email";
    case firebase::auth::kAuthErrorInvalidCredential:
      return "invalid-credential";
    case firebase::auth::kAuthErrorUserDisabled:
      return "user-disabled";
    case firebase::auth::kAuthErrorEmailAlreadyInUse:
      return "email-already-in-use";
    case firebase::auth::kAuthErrorWrongPassword:
      return "wrong-password";
    case firebase::auth::kAuthErrorTooManyRequests:
      return "too-many-requests";
    case firebase::auth::kAuthErrorAccountExistsWithDifferentCredentials:
      return "account-exists-with-different-credentials";
    case firebase::auth::kAuthErrorRequiresRecentLogin:
      return "requires-recent-login";
    case firebase::auth::kAuthErrorProviderAlreadyLinked:
      return "provider-already-linked";
    case firebase::auth::kAuthErrorNoSuchProvider:
      return "no-such-provider";
    case firebase::auth::kAuthErrorInvalidUserToken:
      return "invalid-user-token";
    case firebase::auth::kAuthErrorUserTokenExpired:
      return "user-token-expired";
    case firebase::auth::kAuthErrorUserNotFound:
      return "user-not-found";
    case firebase::auth::kAuthErrorInvalidApiKey:
      return "invalid-api-key";
    case firebase::auth::kAuthErrorCredentialAlreadyInUse:
      return "credential-already-in-use";
    case firebase::auth::kAuthErrorOperationNotAllowed:
      return "operation-not-allowed";
    case firebase::auth::kAuthErrorWeakPassword:
      return "weak-password";
    case firebase::auth::kAuthErrorAppNotAuthorized:
      return "app-not-authorized";
    case firebase::auth::kAuthErrorExpiredActionCode:
      return "expired-action-code";
    case firebase::auth::kAuthErrorInvalidActionCode:
      return "invalid-action-code";
    case firebase::auth::kAuthErrorInvalidMessagePayload:
      return "invalid-message-payload";
    case firebase::auth::kAuthErrorInvalidSender:
      return "invalid-sender";
    case firebase::auth::kAuthErrorInvalidRecipientEmail:
      return "invalid-recipient-email";
    case firebase::auth::kAuthErrorUnauthorizedDomain:
      return "unauthorized-domain";
    case firebase::auth::kAuthErrorInvalidContinueUri:
      return "invalid-continue-uri";
    case firebase::auth::kAuthErrorMissingContinueUri:
      return "missing-continue-uri";
    case firebase::auth::kAuthErrorMissingEmail:
      return "missing-email";
    case firebase::auth::kAuthErrorMissingPhoneNumber:
      return "missing-phone-number";
    case firebase::auth::kAuthErrorInvalidPhoneNumber:
      return "invalid-phone-number";
    case firebase::auth::kAuthErrorMissingVerificationCode:
      return "missing-verification-code";
    case firebase::auth::kAuthErrorInvalidVerificationCode:
      return "invalid-verification-code";
    case firebase::auth::kAuthErrorMissingVerificationId:
      return "missing-verification-id";
    case firebase::auth::kAuthErrorInvalidVerificationId:
      return "invalid-verification-id";
    case firebase::auth::kAuthErrorSessionExpired:
      return "session-expired";
    case firebase::auth::kAuthErrorQuotaExceeded:
      return "quota-exceeded";
    case firebase::auth::kAuthErrorMissingAppCredential:
      return "missing-app-credential";
    case firebase::auth::kAuthErrorInvalidAppCredential:
      return "invalid-app-credential";
    case firebase::auth::kAuthErrorMissingClientIdentifier:
      return "missing-client-identifier";
    case firebase::auth::kAuthErrorTenantIdMismatch:
      return "tenant-id-mismatch";
    case firebase::auth::kAuthErrorUnsupportedTenantOperation:
      return "unsupported-tenant-operation";
    case firebase::auth::kAuthErrorUserMismatch:
      return "user-mismatch";
    case firebase::auth::kAuthErrorNetworkRequestFailed:
      return "network-request-failed";
    case firebase::auth::kAuthErrorNoSignedInUser:
      return "no-signed-in-user";
    case firebase::auth::kAuthErrorCancelled:
      return "cancelled";

    default:
      return "unknown-error";
  }
}

FlutterError FirebaseAuthPlugin::ParseError(
    const firebase::FutureBase& completed_future) {
  const AuthError errorCode =
      static_cast<const AuthError>(completed_future.error());

  return FlutterError(FirebaseAuthPlugin::GetAuthErrorCode(errorCode),
                      completed_future.error_message());
}

std::string const kFLTFirebaseAuthChannelName = "firebase_auth_plugin";

class FlutterIdTokenListener : public firebase::auth::IdTokenListener {
 public:
  void SetEventSink(
      std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> event_sink) {
    event_sink_ = std::move(event_sink);
  }

  void OnIdTokenChanged(Auth* auth) override {
    // Generate your ID Token
    firebase::auth::User user = auth->current_user();
    PigeonUserDetails userDetails = FirebaseAuthPlugin::ParseUserDetails(user);

    using flutter::EncodableList;
    using flutter::EncodableMap;
    using flutter::EncodableValue;

    if (event_sink_) {
      if (user.is_valid()) {
        EncodableList userDetailsList = EncodableList();
        userDetailsList.push_back(userDetails.user_info().ToEncodableList());
        userDetailsList.push_back(userDetails.provider_data());
        event_sink_->Success(EncodableValue(
            EncodableMap{{EncodableValue("user"), userDetailsList}}));
      } else {
        event_sink_->Success(EncodableValue(EncodableMap{
            {EncodableValue("user"), EncodableValue(std::monostate{})}}));
      }
    }
  }

 private:
  std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> event_sink_;
};

class IdTokenStreamHandler
    : public flutter::StreamHandler<flutter::EncodableValue> {
 public:
  IdTokenStreamHandler(Auth* auth) {
    listener_ = nullptr;
    auth_ = auth;
  }

  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
  OnListenInternal(
      const flutter::EncodableValue* arguments,
      std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events)
      override {
    listener_ = new FlutterIdTokenListener();
    listener_->SetEventSink(std::move(events));
    auth_->AddIdTokenListener(listener_);
    return nullptr;
  }

  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
  OnCancelInternal(const flutter::EncodableValue* arguments) override {
    auth_->RemoveIdTokenListener(listener_);
    listener_->SetEventSink(nullptr);
    listener_ = nullptr;
    return nullptr;
  }

 private:
  FlutterIdTokenListener* listener_;
  firebase::auth::Auth* auth_;
};

void FirebaseAuthPlugin::RegisterIdTokenListener(
    const AuthPigeonFirebaseApp& app,
    std::function<void(ErrorOr<std::string> reply)> result) {
  firebase::auth::Auth* firebaseAuth = GetAuthFromPigeon(app);

  std::string name =
      kFLTFirebaseAuthChannelName + "/id-token/" + app.app_name();

  auto id_token_handler = std::make_unique<IdTokenStreamHandler>(firebaseAuth);

  flutter::EventChannel<flutter::EncodableValue> channel(
      binaryMessenger, name, &flutter::StandardMethodCodec::GetInstance());

  channel.SetStreamHandler(std::move(id_token_handler));

  result(ErrorOr<std::string>(std::string(name)));
}

class FlutterAuthStateListener : public firebase::auth::AuthStateListener {
 public:
  void SetEventSink(
      std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> event_sink) {
    event_sink_ = std::move(event_sink);
  }

  void OnAuthStateChanged(Auth* auth) override {
    // Generate your ID Token
    firebase::auth::User user = auth->current_user();
    PigeonUserDetails userDetails = FirebaseAuthPlugin::ParseUserDetails(user);

    using flutter::EncodableList;
    using flutter::EncodableMap;
    using flutter::EncodableValue;

    if (event_sink_) {
      if (user.is_valid()) {
        EncodableList userDetailsList = EncodableList();
        userDetailsList.push_back(userDetails.user_info().ToEncodableList());
        userDetailsList.push_back(userDetails.provider_data());

        event_sink_->Success(EncodableValue(
            EncodableMap{{EncodableValue("user"), userDetailsList}}));
      } else {
        event_sink_->Success(EncodableValue(EncodableMap{
            {EncodableValue("user"), EncodableValue(std::monostate{})}}));
      }
    }
  }

 private:
  std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> event_sink_;
};

class AuthStateStreamHandler
    : public flutter::StreamHandler<flutter::EncodableValue> {
 public:
  AuthStateStreamHandler(Auth* auth) {
    listener_ = nullptr;
    auth_ = auth;
  }

  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
  OnListenInternal(
      const flutter::EncodableValue* arguments,
      std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events)
      override {
    listener_ = new FlutterAuthStateListener();
    listener_->SetEventSink(std::move(events));

    auth_->AddAuthStateListener(listener_);

    return nullptr;
  }

  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
  OnCancelInternal(const flutter::EncodableValue* arguments) override {
    auth_->RemoveAuthStateListener(listener_);

    listener_->SetEventSink(nullptr);
    listener_ = nullptr;
    return nullptr;
  }

 private:
  FlutterAuthStateListener* listener_;
  firebase::auth::Auth* auth_;
};

void FirebaseAuthPlugin::RegisterAuthStateListener(
    const AuthPigeonFirebaseApp& app,
    std::function<void(ErrorOr<std::string> reply)> result) {
  firebase::auth::Auth* firebaseAuth = GetAuthFromPigeon(app);

  std::string name =
      kFLTFirebaseAuthChannelName + "/auth-state/" + app.app_name();

  auto auth_state_handler =
      std::make_unique<AuthStateStreamHandler>(firebaseAuth);

  flutter::EventChannel<flutter::EncodableValue> channel(
      binaryMessenger, name, &flutter::StandardMethodCodec::GetInstance());

  channel.SetStreamHandler(std::move(auth_state_handler));

  result(ErrorOr<std::string>(std::string(name)));
}

void FirebaseAuthPlugin::UseEmulator(
    const AuthPigeonFirebaseApp& app, const std::string& host, int64_t port,
    std::function<void(std::optional<FlutterError> reply)> result) {
  firebase::auth::Auth* firebaseAuth = GetAuthFromPigeon(app);
  firebaseAuth->UseEmulator(host, static_cast<uint32_t>(port));
  result(std::nullopt);
}

void FirebaseAuthPlugin::ApplyActionCode(
    const AuthPigeonFirebaseApp& app, const std::string& code,
    std::function<void(std::optional<FlutterError> reply)> result) {
  result(FlutterError("unimplemented",
                      "ApplyActionCode is not available on this platform yet.",
                      nullptr));
}

void FirebaseAuthPlugin::CheckActionCode(
    const AuthPigeonFirebaseApp& app, const std::string& code,
    std::function<void(ErrorOr<PigeonActionCodeInfo> reply)> result) {
  result(FlutterError("unimplemented",
                      "CheckActionCode is not available on this platform yet.",
                      nullptr));
}

void FirebaseAuthPlugin::ConfirmPasswordReset(
    const AuthPigeonFirebaseApp& app, const std::string& code,
    const std::string& new_password,
    std::function<void(std::optional<FlutterError> reply)> result) {
  result(FlutterError(
      "unimplemented",
      "ConfirmPasswordReset is not available on this platform yet.", nullptr));
}

void FirebaseAuthPlugin::CreateUserWithEmailAndPassword(
    const AuthPigeonFirebaseApp& app, const std::string& email,
    const std::string& password,
    std::function<void(ErrorOr<PigeonUserCredential> reply)> result) {
  firebase::auth::Auth* firebaseAuth = GetAuthFromPigeon(app);

  firebase::Future<firebase::auth::AuthResult> createUserFuture =
      firebaseAuth->CreateUserWithEmailAndPassword(email.c_str(),
                                                   password.c_str());

  createUserFuture.OnCompletion(
      [result](const firebase::Future<firebase::auth::AuthResult>&
                   completed_future) {
        // We are probably in a different thread right now.
        if (completed_future.error() == 0) {
          PigeonUserCredential credential =
              ParseAuthResult(completed_future.result());
          result(credential);
        } else {
          result(FirebaseAuthPlugin::ParseError(completed_future));
        }
      });
}

void FirebaseAuthPlugin::SignInAnonymously(
    const AuthPigeonFirebaseApp& app,
    std::function<void(ErrorOr<PigeonUserCredential> reply)> result) {
  firebase::auth::Auth* firebaseAuth = GetAuthFromPigeon(app);

  firebase::Future<firebase::auth::AuthResult> signInFuture =
      firebaseAuth->SignInAnonymously();

  signInFuture.OnCompletion(
      [result](const firebase::Future<firebase::auth::AuthResult>&
                   completed_future) {
        // We are probably in a different thread right now.
        if (completed_future.error() == 0) {
          PigeonUserCredential credential =
              ParseAuthResult(completed_future.result());
          result(credential);
        } else {
          result(FirebaseAuthPlugin::ParseError(completed_future));
        }
      });
}

// Provider type keys.
std::string const kSignInMethodPassword = "password";
std::string const kSignInMethodEmailLink = "emailLink";
std::string const kSignInMethodFacebook = "facebook.com";
std::string const kSignInMethodGoogle = "google.com";
std::string const kSignInMethodTwitter = "twitter.com";
std::string const kSignInMethodGithub = "github.com";
std::string const kSignInMethodApple = "apple.com";
std::string const kSignInMethodPhone = "phone";
std::string const kSignInMethodOAuth = "oauth";

// Credential argument keys.
std::string const kArgumentCredential = "credential";
std::string const kArgumentProviderId = "providerId";
std::string const kArgumentProviderScope = "scopes";
std::string const kArgumentProviderCustomParameters = "customParameters";
std::string const kArgumentSignInMethod = "signInMethod";
std::string const kArgumentSecret = "secret";
std::string const kArgumentIdToken = "idToken";
std::string const kArgumentAccessToken = "accessToken";
std::string const kArgumentRawNonce = "rawNonce";
std::string const kArgumentEmail = "email";
std::string const kArgumentCode = "code";
std::string const kArgumentNewEmail = "newEmail";
std::string const kArgumentEmailLink = kSignInMethodEmailLink;
std::string const kArgumentToken = "token";
std::string const kArgumentVerificationId = "verificationId";
std::string const kArgumentSmsCode = "smsCode";
std::string const kArgumentActionCodeSettings = "actionCodeSettings";

// Emulating NSDictionary
typedef std::unordered_map<std::string, std::string> Dictionary;

firebase::auth::Credential getCredentialFromArguments(
    flutter::EncodableMap arguments, const AuthPigeonFirebaseApp& app) {
  std::string signInMethod =
      std::get<std::string>(arguments[kArgumentSignInMethod]);

  // Password Auth
  if (signInMethod == kSignInMethodPassword) {
    std::string email = std::get<std::string>(arguments[kArgumentEmail]);
    std::string secret = std::get<std::string>(arguments[kArgumentSecret]);
    return firebase::auth::EmailAuthProvider::GetCredential(email.c_str(),
                                                            secret.c_str());
  }

  // Email Link Auth
  if (signInMethod == kSignInMethodEmailLink) {
    // Firebase C++ SDK doesn't have email link authentication as of my
    // knowledge cutoff in September 2021
    std::cout << "Email link authentication is not supported in Firebase C++ "
                 "SDK as of September 2021.\n";
    return firebase::auth::Credential();
  }

  // Lambda function to extract an optional string from the arguments map. This
  // allows us to pass nullptr if no value exists
  auto getStringOpt =
      [&](const std::string& key) -> std::optional<std::string> {
    auto it = arguments.find(key);
    if (it != arguments.end() &&
        std::holds_alternative<std::string>(it->second)) {
      return std::get<std::string>(it->second);
    }
    return std::nullopt;
  };

  std::optional<std::string> idToken = getStringOpt(kArgumentIdToken);
  std::optional<std::string> accessToken = getStringOpt(kArgumentAccessToken);

  // Facebook Auth
  if (signInMethod == kSignInMethodFacebook) {
    return firebase::auth::FacebookAuthProvider::GetCredential(
        accessToken.value().c_str());
  }

  // Google Auth
  if (signInMethod == kSignInMethodGoogle) {
    // Both accessToken and idToken arguments can be null. You can use one or
    // the other
    return firebase::auth::GoogleAuthProvider::GetCredential(
        idToken ? idToken.value().c_str() : nullptr,
        accessToken ? accessToken.value().c_str() : nullptr);
  }

  // Twitter Auth
  if (signInMethod == kSignInMethodTwitter) {
    std::string secret = std::get<std::string>(arguments[kArgumentSecret]);
    return firebase::auth::TwitterAuthProvider::GetCredential(
        idToken.value().c_str(), secret.c_str());
  }

  // GitHub Auth
  if (signInMethod == kSignInMethodGithub) {
    return firebase::auth::GitHubAuthProvider::GetCredential(
        accessToken.value().c_str());
  }

  // OAuth
  if (signInMethod == kSignInMethodOAuth) {
    std::string providerId =
        std::get<std::string>(arguments[kArgumentProviderId]);
    std::optional<std::string> rawNonce = getStringOpt(kArgumentRawNonce);
    // If rawNonce provided use corresponding credential builder
    // e.g. AppleID auth through the webView
    if (rawNonce) {
      return firebase::auth::OAuthProvider::GetCredential(
          providerId.c_str(), idToken.value().c_str(), rawNonce.value().c_str(),
          accessToken ? accessToken.value().c_str() : nullptr);
    } else {
      return firebase::auth::OAuthProvider::GetCredential(
          providerId.c_str(), idToken.value().c_str(),
          accessToken.value().c_str());
    }
  }

  // If no known auth method matched
  printf(
      "Support for an auth provider with identifier '%s' is not implemented.\n",
      signInMethod.c_str());
  return firebase::auth::Credential();
}

void FirebaseAuthPlugin::SignInWithCredential(
    const AuthPigeonFirebaseApp& app, const flutter::EncodableMap& input,
    std::function<void(ErrorOr<PigeonUserCredential> reply)> result) {
  firebase::auth::Auth* firebaseAuth = GetAuthFromPigeon(app);

  firebase::Future<firebase::auth::User> signInFuture =
      firebaseAuth->SignInWithCredential(
          getCredentialFromArguments(input, app));

  signInFuture.OnCompletion(
      [result](const firebase::Future<firebase::auth::User>& completed_future) {
        if (completed_future.error() == 0) {
          // TODO: not the right return type from C++ SDK
          PigeonUserInfo credential = ParseUserInfo(completed_future.result());
          PigeonUserCredential userCredential = PigeonUserCredential();
          PigeonUserDetails user =
              PigeonUserDetails(credential, flutter::EncodableList());
          userCredential.set_user(user);
          result(userCredential);
        } else {
          result(FirebaseAuthPlugin::ParseError(completed_future));
        }
      });
}

void FirebaseAuthPlugin::SignInWithCustomToken(
    const AuthPigeonFirebaseApp& app, const std::string& token,
    std::function<void(ErrorOr<PigeonUserCredential> reply)> result) {
  firebase::auth::Auth* firebaseAuth = GetAuthFromPigeon(app);

  firebase::Future<firebase::auth::AuthResult> signInFuture =
      firebaseAuth->SignInWithCustomToken(token.c_str());

  signInFuture.OnCompletion(
      [result](const firebase::Future<firebase::auth::AuthResult>&
                   completed_future) {
        // We are probably in a different thread right now.
        if (completed_future.error() == 0) {
          PigeonUserCredential credential =
              ParseAuthResult(completed_future.result());
          result(credential);
        } else {
          result(FirebaseAuthPlugin::ParseError(completed_future));
        }
      });
}

void FirebaseAuthPlugin::SignInWithEmailAndPassword(
    const AuthPigeonFirebaseApp& app, const std::string& email,
    const std::string& password,
    std::function<void(ErrorOr<PigeonUserCredential> reply)> result) {
  firebase::auth::Auth* firebaseAuth = GetAuthFromPigeon(app);

  firebase::Future<firebase::auth::AuthResult> signInFuture =
      firebaseAuth->SignInWithEmailAndPassword(email.c_str(), password.c_str());

  signInFuture.OnCompletion(
      [result](const firebase::Future<firebase::auth::AuthResult>&
                   completed_future) {
        // We are probably in a different thread right now.
        if (completed_future.error() == 0) {
          PigeonUserCredential credential =
              ParseAuthResult(completed_future.result());
          result(credential);
        } else {
          result(FirebaseAuthPlugin::ParseError(completed_future));
        }
      });
}

void FirebaseAuthPlugin::SignInWithEmailLink(
    const AuthPigeonFirebaseApp& app, const std::string& email,
    const std::string& email_link,
    std::function<void(ErrorOr<PigeonUserCredential> reply)> result) {
  result(FlutterError(
      "unimplemented",
      "SignInWithEmailLink is not available on this platform yet.", nullptr));
}

std::vector<std::string> TransformEncodableList(
    const flutter::EncodableList& encodable_list) {
  std::vector<std::string> transformed_list;

  for (const auto& value : encodable_list) {
    if (std::holds_alternative<std::string>(value)) {
      transformed_list.push_back(std::get<std::string>(value));
    }
  }

  return transformed_list;
}

std::map<std::string, std::string> TransformEncodableMap(
    const flutter::EncodableMap& encodable_map) {
  std::map<std::string, std::string> transformed_map;

  for (const auto& pair : encodable_map) {
    if (std::holds_alternative<std::string>(pair.first) &&
        std::holds_alternative<std::string>(pair.second)) {
      transformed_map[std::get<std::string>(pair.first)] =
          std::get<std::string>(pair.second);
    }
  }

  return transformed_map;
}

firebase::auth::FederatedOAuthProvider getProviderFromArguments(
    const PigeonSignInProvider& sign_in_provider) {
  firebase::auth::FederatedOAuthProviderData federatedOAuthProviderData =
      firebase::auth::FederatedOAuthProviderData(
          sign_in_provider.provider_id().c_str(),
          TransformEncodableList(*sign_in_provider.scopes()),
          TransformEncodableMap(*sign_in_provider.custom_parameters()));
  firebase::auth::FederatedOAuthProvider federatedAuthProvider =
      firebase::auth::FederatedOAuthProvider(federatedOAuthProviderData);

  return federatedAuthProvider;
}

void FirebaseAuthPlugin::SignInWithProvider(
    const AuthPigeonFirebaseApp& app,
    const PigeonSignInProvider& sign_in_provider,
    std::function<void(ErrorOr<PigeonUserCredential> reply)> result) {
  firebase::auth::Auth* firebaseAuth = GetAuthFromPigeon(app);

  firebase::Future<firebase::auth::AuthResult> signInFuture =
      firebaseAuth->SignInWithProvider(
          &getProviderFromArguments(sign_in_provider));

  signInFuture.OnCompletion(
      [result](const firebase::Future<firebase::auth::AuthResult>&
                   completed_future) {
        // We are probably in a different thread right now.
        if (completed_future.error() == 0) {
          PigeonUserCredential credential =
              ParseAuthResult(completed_future.result());
          result(credential);
        } else {
          result(FirebaseAuthPlugin::ParseError(completed_future));
        }
      });
}

void FirebaseAuthPlugin::SignOut(
    const AuthPigeonFirebaseApp& app,
    std::function<void(std::optional<FlutterError> reply)> result) {
  firebase::auth::Auth* firebaseAuth = GetAuthFromPigeon(app);

  firebaseAuth->SignOut();

  result(std::nullopt);
}

flutter::EncodableList TransformStringList(
    const std::vector<std::string>& string_list) {
  flutter::EncodableList encodable_list;

  for (const auto& value : string_list) {
    encodable_list.push_back(value);
  }

  return encodable_list;
}

void FirebaseAuthPlugin::FetchSignInMethodsForEmail(
    const AuthPigeonFirebaseApp& app, const std::string& email,
    std::function<void(ErrorOr<flutter::EncodableList> reply)> result) {
  firebase::auth::Auth* firebaseAuth = GetAuthFromPigeon(app);

  firebase::Future<firebase::auth::Auth::FetchProvidersResult> signInFuture =
      firebaseAuth->FetchProvidersForEmail(email.c_str());

  signInFuture.OnCompletion(
      [result](
          const firebase::Future<firebase::auth::Auth::FetchProvidersResult>&
              completed_future) {
        // We are probably in a different thread right now.
        if (completed_future.error() == 0) {
          result(TransformStringList(completed_future.result()->providers));
        } else {
          result(FirebaseAuthPlugin::ParseError(completed_future));
        }
      });
}

void FirebaseAuthPlugin::SendPasswordResetEmail(
    const AuthPigeonFirebaseApp& app, const std::string& email,
    const PigeonActionCodeSettings* action_code_settings,
    std::function<void(std::optional<FlutterError> reply)> result) {
  firebase::auth::Auth* firebaseAuth = GetAuthFromPigeon(app);

  firebase::Future<void> signInFuture =
      firebaseAuth->SendPasswordResetEmail(email.c_str());

  signInFuture.OnCompletion(
      [result](const firebase::Future<void>& completed_future) {
        // We are probably in a different thread right now.
        if (completed_future.error() == 0) {
          result(std::nullopt);
        } else {
          result(FirebaseAuthPlugin::ParseError(completed_future));
        }
      });
}

void FirebaseAuthPlugin::SendSignInLinkToEmail(
    const AuthPigeonFirebaseApp& app, const std::string& email,
    const PigeonActionCodeSettings& action_code_settings,
    std::function<void(std::optional<FlutterError> reply)> result) {
  result(FlutterError(
      "unimplemented",
      "SendSignInLinkToEmail is not available on this platform yet.", nullptr));
}

void FirebaseAuthPlugin::SetLanguageCode(
    const AuthPigeonFirebaseApp& app, const std::string* language_code,
    std::function<void(ErrorOr<std::string> reply)> result) {
  firebase::auth::Auth* firebaseAuth = GetAuthFromPigeon(app);

  if (language_code == nullptr) {
    firebaseAuth->UseAppLanguage();
    result(firebaseAuth->language_code());
    return;
  }

  firebaseAuth->set_language_code(language_code->c_str());

  result(*language_code);
}

void FirebaseAuthPlugin::SetSettings(
    const AuthPigeonFirebaseApp& app,
    const PigeonFirebaseAuthSettings& settings,
    std::function<void(std::optional<FlutterError> reply)> result) {
  result(FlutterError("unimplemented",
                      "SetSettings is not available on this platform yet.",
                      nullptr));
}

void FirebaseAuthPlugin::VerifyPasswordResetCode(
    const AuthPigeonFirebaseApp& app, const std::string& code,
    std::function<void(ErrorOr<std::string> reply)> result) {
  result(FlutterError(
      "unimplemented",
      "VerifyPasswordResetCode is not available on this platform yet.",
      nullptr));
}

void FirebaseAuthPlugin::VerifyPhoneNumber(
    const AuthPigeonFirebaseApp& app,
    const PigeonVerifyPhoneNumberRequest& request,
    std::function<void(ErrorOr<std::string> reply)> result) {
  result(FlutterError(
      "unimplemented",
      "VerifyPhoneNumber is not available on this platform yet.", nullptr));
}

void FirebaseAuthPlugin::Delete(
    const AuthPigeonFirebaseApp& app,
    std::function<void(std::optional<FlutterError> reply)> result) {
  firebase::auth::Auth* firebaseAuth = GetAuthFromPigeon(app);
  firebase::auth::User user = firebaseAuth->current_user();

  firebase::Future<void> future = user.Delete();

  future.OnCompletion([result](const firebase::Future<void>& completed_future) {
    // We are probably in a different thread right now.
    if (completed_future.error() == 0) {
      result(std::nullopt);
    } else {
      result(FirebaseAuthPlugin::ParseError(completed_future));
    }
  });
}

void FirebaseAuthPlugin::GetIdToken(
    const AuthPigeonFirebaseApp& app, bool force_refresh,
    std::function<void(ErrorOr<PigeonIdTokenResult> reply)> result) {
  firebase::auth::Auth* firebaseAuth = GetAuthFromPigeon(app);
  firebase::auth::User user = firebaseAuth->current_user();

  firebase::Future<std::string> future = user.GetToken(force_refresh);

  future.OnCompletion(
      [result](const firebase::Future<std::string>& completed_future) {
        // We are probably in a different thread right now.
        if (completed_future.error() == 0) {
          PigeonIdTokenResult token_result;
          std::string_view sv(*completed_future.result());
          token_result.set_token(sv);
          result(token_result);
        } else {
          result(FirebaseAuthPlugin::ParseError(completed_future));
        }
      });
}

void FirebaseAuthPlugin::LinkWithCredential(
    const AuthPigeonFirebaseApp& app, const flutter::EncodableMap& input,
    std::function<void(ErrorOr<PigeonUserCredential> reply)> result) {
  firebase::auth::Auth* firebaseAuth = GetAuthFromPigeon(app);
  firebase::auth::User user = firebaseAuth->current_user();

  firebase::Future<firebase::auth::AuthResult> future =
      user.LinkWithCredential(getCredentialFromArguments(input, app));

  future.OnCompletion(
      [result](const firebase::Future<firebase::auth::AuthResult>&
                   completed_future) {
        // We are probably in a different thread right now.
        if (completed_future.error() == 0) {
          PigeonUserCredential credential =
              ParseAuthResult(completed_future.result());
          result(credential);
        } else {
          result(FirebaseAuthPlugin::ParseError(completed_future));
        }
      });
}

void FirebaseAuthPlugin::LinkWithProvider(
    const AuthPigeonFirebaseApp& app,
    const PigeonSignInProvider& sign_in_provider,
    std::function<void(ErrorOr<PigeonUserCredential> reply)> result) {
  firebase::auth::Auth* firebaseAuth = GetAuthFromPigeon(app);
  firebase::auth::User user = firebaseAuth->current_user();

  firebase::Future<firebase::auth::AuthResult> future =
      user.LinkWithProvider(&getProviderFromArguments(sign_in_provider));

  future.OnCompletion(
      [result](const firebase::Future<firebase::auth::AuthResult>&
                   completed_future) {
        // We are probably in a different thread right now.
        if (completed_future.error() == 0) {
          PigeonUserCredential credential =
              ParseAuthResult(completed_future.result());
          result(credential);
        } else {
          result(FirebaseAuthPlugin::ParseError(completed_future));
        }
      });
}

void FirebaseAuthPlugin::ReauthenticateWithCredential(
    const AuthPigeonFirebaseApp& app, const flutter::EncodableMap& input,
    std::function<void(ErrorOr<PigeonUserCredential> reply)> result) {
  firebase::auth::Auth* firebaseAuth = GetAuthFromPigeon(app);
  firebase::auth::User user = firebaseAuth->current_user();

  firebase::Future<void> future =
      user.Reauthenticate(getCredentialFromArguments(input, app));

  future.OnCompletion([result](const firebase::Future<void>& completed_future) {
    // We are probably in a different thread right now.
    if (completed_future.error() == 0) {
      // TODO: wrong return type
    } else {
      result(FirebaseAuthPlugin::ParseError(completed_future));
    }
  });
}

void FirebaseAuthPlugin::ReauthenticateWithProvider(
    const AuthPigeonFirebaseApp& app,
    const PigeonSignInProvider& sign_in_provider,
    std::function<void(ErrorOr<PigeonUserCredential> reply)> result) {
  firebase::auth::Auth* firebaseAuth = GetAuthFromPigeon(app);
  firebase::auth::User user = firebaseAuth->current_user();

  firebase::Future<firebase::auth::AuthResult> future =
      user.ReauthenticateWithProvider(
          &getProviderFromArguments(sign_in_provider));

  future.OnCompletion(
      [result](const firebase::Future<firebase::auth::AuthResult>&
                   completed_future) {
        // We are probably in a different thread right now.
        if (completed_future.error() == 0) {
          PigeonUserCredential credential =
              ParseAuthResult(completed_future.result());
          result(credential);
        } else {
          result(FirebaseAuthPlugin::ParseError(completed_future));
        }
      });
}

void FirebaseAuthPlugin::Reload(
    const AuthPigeonFirebaseApp& app,
    std::function<void(ErrorOr<PigeonUserDetails> reply)> result) {
  firebase::auth::Auth* firebaseAuth = GetAuthFromPigeon(app);
  firebase::auth::User user = firebaseAuth->current_user();

  firebase::Future<void> future = user.Reload();

  future.OnCompletion([result, firebaseAuth](
                          const firebase::Future<void>& completed_future) {
    // We are probably in a different thread right now.
    if (completed_future.error() == 0) {
      PigeonUserDetails user = ParseUserDetails(firebaseAuth->current_user());
      result(user);
    } else {
      result(FirebaseAuthPlugin::ParseError(completed_future));
    }
  });
}

void FirebaseAuthPlugin::SendEmailVerification(
    const AuthPigeonFirebaseApp& app,
    const PigeonActionCodeSettings* action_code_settings,
    std::function<void(std::optional<FlutterError> reply)> result) {
  firebase::auth::Auth* firebaseAuth = GetAuthFromPigeon(app);
  firebase::auth::User user = firebaseAuth->current_user();

  firebase::Future<void> future = user.SendEmailVerification();

  future.OnCompletion([result](const firebase::Future<void>& completed_future) {
    // We are probably in a different thread right now.
    if (completed_future.error() == 0) {
      result(std::nullopt);
    } else {
      result(FirebaseAuthPlugin::ParseError(completed_future));
    }
  });
}

void FirebaseAuthPlugin::Unlink(
    const AuthPigeonFirebaseApp& app, const std::string& provider_id,
    std::function<void(ErrorOr<PigeonUserCredential> reply)> result) {
  firebase::auth::Auth* firebaseAuth = GetAuthFromPigeon(app);
  firebase::auth::User user = firebaseAuth->current_user();

  firebase::Future<firebase::auth::AuthResult> future =
      user.Unlink(provider_id.c_str());

  future.OnCompletion(
      [result](const firebase::Future<firebase::auth::AuthResult>&
                   completed_future) {
        // We are probably in a different thread right now.
        if (completed_future.error() == 0) {
          PigeonUserCredential credential =
              ParseAuthResult(completed_future.result());
          result(credential);
        } else {
          result(FirebaseAuthPlugin::ParseError(completed_future));
        }
      });
}

void FirebaseAuthPlugin::UpdateEmail(
    const AuthPigeonFirebaseApp& app, const std::string& new_email,
    std::function<void(ErrorOr<PigeonUserDetails> reply)> result) {
  firebase::auth::Auth* firebaseAuth = GetAuthFromPigeon(app);
  firebase::auth::User user = firebaseAuth->current_user();

#pragma warning(push)
#pragma warning(disable : 4996)
  firebase::Future<void> future = user.UpdateEmail(new_email.c_str());
#pragma warning(pop)

  future.OnCompletion([result, firebaseAuth](
                          const firebase::Future<void>& completed_future) {
    // We are probably in a different thread right now.
    if (completed_future.error() == 0) {
      PigeonUserDetails user = ParseUserDetails(firebaseAuth->current_user());
      result(user);
    } else {
      result(FirebaseAuthPlugin::ParseError(completed_future));
    }
  });
}

void FirebaseAuthPlugin::UpdatePassword(
    const AuthPigeonFirebaseApp& app, const std::string& new_password,
    std::function<void(ErrorOr<PigeonUserDetails> reply)> result) {
  firebase::auth::Auth* firebaseAuth = GetAuthFromPigeon(app);
  firebase::auth::User user = firebaseAuth->current_user();

  firebase::Future<void> future = user.UpdatePassword(new_password.c_str());

  future.OnCompletion([result, firebaseAuth](
                          const firebase::Future<void>& completed_future) {
    // We are probably in a different thread right now.
    if (completed_future.error() == 0) {
      PigeonUserDetails user = ParseUserDetails(firebaseAuth->current_user());
      result(user);
    } else {
      result(FirebaseAuthPlugin::ParseError(completed_future));
    }
  });
}

firebase::auth::PhoneAuthCredential getPhoneCredentialFromArguments(
    flutter::EncodableMap arguments, const AuthPigeonFirebaseApp& app) {
  std::string signInMethod =
      std::get<std::string>(arguments[kArgumentSignInMethod]);

  if (signInMethod == kSignInMethodPhone) {
    std::string verificationId =
        std::get<std::string>(arguments[kArgumentVerificationId]);
    std::string smsCode = std::get<std::string>(arguments[kArgumentSmsCode]);

    // TODO: we cannot construct a PhoneAuthCredential from the verificationId
    return firebase::auth::PhoneAuthCredential::PhoneAuthCredential();
  }
  // If no known auth method matched
  printf(
      "Support for an auth provider with identifier '%s' is not "
      "implemented.\n",
      signInMethod.c_str());
  throw;
}

void FirebaseAuthPlugin::UpdatePhoneNumber(
    const AuthPigeonFirebaseApp& app, const flutter::EncodableMap& input,
    std::function<void(ErrorOr<PigeonUserDetails> reply)> result) {
  firebase::auth::Auth* firebaseAuth = GetAuthFromPigeon(app);
  firebase::auth::User user = firebaseAuth->current_user();

  firebase::Future<firebase::auth::User> future =
      user.UpdatePhoneNumberCredential(
          getPhoneCredentialFromArguments(input, app));

  future.OnCompletion(
      [result](const firebase::Future<firebase::auth::User>& completed_future) {
        // We are probably in a different thread right now.
        if (completed_future.error() == 0) {
          PigeonUserDetails user = ParseUserDetails(*completed_future.result());
          result(user);
        } else {
          result(FirebaseAuthPlugin::ParseError(completed_future));
        }
      });
}

void FirebaseAuthPlugin::UpdateProfile(
    const AuthPigeonFirebaseApp& app, const PigeonUserProfile& profile,
    std::function<void(ErrorOr<PigeonUserDetails> reply)> result) {
  firebase::auth::Auth* firebaseAuth = GetAuthFromPigeon(app);
  firebase::auth::User user = firebaseAuth->current_user();

  firebase::auth::User::UserProfile userProfile;

  if (profile.display_name_changed()) {
    userProfile.display_name = profile.display_name()->c_str();
  }
  if (profile.photo_url_changed()) {
    userProfile.photo_url = profile.photo_url()->c_str();
  }

  firebase::Future<void> future = user.UpdateUserProfile(userProfile);

  future.OnCompletion([result, firebaseAuth](
                          const firebase::Future<void>& completed_future) {
    // We are probably in a different thread right now.
    if (completed_future.error() == 0) {
      PigeonUserDetails user = ParseUserDetails(firebaseAuth->current_user());
      result(user);
    } else {
      result(FirebaseAuthPlugin::ParseError(completed_future));
    }
  });
}

void FirebaseAuthPlugin::VerifyBeforeUpdateEmail(
    const AuthPigeonFirebaseApp& app, const std::string& new_email,
    const PigeonActionCodeSettings* action_code_settings,
    std::function<void(std::optional<FlutterError> reply)> result) {
  firebase::auth::Auth* firebaseAuth = GetAuthFromPigeon(app);
  firebase::auth::User user = firebaseAuth->current_user();

  if (action_code_settings != nullptr) {
    printf(
        "Firebase C++ SDK does not support using `ActionCodeSettings` for "
        "`verifyBeforeUpdateEmail()` API currently");
  }

  firebase::Future<void> future =
      user.SendEmailVerificationBeforeUpdatingEmail(new_email.c_str());

  future.OnCompletion(
      [result, firebaseAuth](const firebase::Future<void>& completed_future) {
        if (completed_future.error() == 0) {
          result(std::nullopt);
        } else {
          result(FirebaseAuthPlugin::ParseError(completed_future));
        }
      });
}

void FirebaseAuthPlugin::RevokeTokenWithAuthorizationCode(
    const AuthPigeonFirebaseApp& app, const std::string& authorization_code,
    std::function<void(std::optional<FlutterError> reply)> result) {
  result(FlutterError(
      "unimplemented",
      "RevokeTokenWithAuthorizationCode is not available on this platform yet.",
      nullptr));
}

}  // namespace firebase_auth_windows
