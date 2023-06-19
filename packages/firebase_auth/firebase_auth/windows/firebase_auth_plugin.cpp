#include "firebase_auth_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

#include "firebase/app.h"
#include "firebase/future.h"
#include "firebase/auth.h"
#include "firebase/util.h"
#include "messages.g.h"
#include <chrono>
#include <thread>

#include "firebase_core/firebase_core_plugin_c_api.h"

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>
#include <flutter/event_channel.h>

#include <future>
#include <iostream>
#include <memory>
#include <sstream>
#include <stdexcept>
#include <string>
#include <unordered_map>
#include <string_view>

using ::firebase::App;
using ::firebase::auth::Auth;

namespace firebase_auth_windows {
flutter::BinaryMessenger* FirebaseAuthPlugin::binaryMessenger = nullptr;

// static
void FirebaseAuthPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto plugin = std::make_unique<FirebaseAuthPlugin>();

  FirebaseAuthHostApi::SetUp(registrar->messenger(), plugin.get());
  FirebaseAuthUserHostApi::SetUp(registrar->messenger(), plugin.get());

  registrar->AddPlugin(std::move(plugin));

  binaryMessenger = registrar->messenger();
}

FirebaseAuthPlugin::FirebaseAuthPlugin() {}

FirebaseAuthPlugin::~FirebaseAuthPlugin() = default;

 firebase::auth::Auth* GetAuthFromPigeon(
    const PigeonFirebaseApp& pigeonApp) {   
  // std::shared_ptr<App> app = GetFirebaseApp(pigeonApp.app_name());

     firebase::AppOptions options;
  options.set_api_key("AIzaSyDooSUGSf63Ghq02_iIhtnmwMDs4HlWS6c");
     options.set_app_id("1:406099696497:ios:58cbc26aca8e5cf83574d0");
  options.set_database_url("https://flutterfire-e2e-tests-default-rtdb.europe-west1.firebasedatabase.app");
  
  options.set_messaging_sender_id("406099696497");

  options.set_project_id("flutterfire-e2e-tests");

    options.set_storage_bucket("flutterfire-e2e-tests.appspot.com");
  

  App* app =
      App::Create(options, pigeonApp.app_name().c_str());



  Auth* auth = Auth::GetAuth(app);

  // firebase::auth::Auth* auth = firebase::auth::Auth::GetAuth(app.get());

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

    using flutter::EncodableMap;
    using flutter::EncodableValue;

    if (event_sink_) {
      if (user.is_valid()) {
        event_sink_->Success(EncodableValue(EncodableMap{
            {EncodableValue("user"), userDetails.ToEncodableList()}}));
      }
      else {
        event_sink_->Success(EncodableValue(
            EncodableMap{{EncodableValue("user"), nullptr}}));
      }
    }
  }

 private:
  std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> event_sink_;
 };


class IdTokenStreamHandler
     : public flutter::StreamHandler<flutter::EncodableValue> {
 public:
  IdTokenStreamHandler() {
    listener_ = nullptr;
  }

  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
  OnListenInternal(
      const flutter::EncodableValue* arguments,
      std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events)
      override {
    listener_ = new FlutterIdTokenListener();
    listener_->SetEventSink(std::move(events));
    return nullptr;
  }

  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
  OnCancelInternal(const flutter::EncodableValue* arguments) override {
    listener_->SetEventSink(nullptr);
    listener_ = nullptr;
    return nullptr;
  }

 private:
  FlutterIdTokenListener* listener_;
 };


void FirebaseAuthPlugin::RegisterIdTokenListener(
    const PigeonFirebaseApp &app,
    std::function<void(ErrorOr<std::string> reply)> result) {

      std::string name =
      kFLTFirebaseAuthChannelName + "/id-token/" + app.app_name();

      auto id_token_handler =
          std::make_unique<IdTokenStreamHandler>();

      flutter::EventChannel<flutter::EncodableValue> channel(
          binaryMessenger, name, &flutter::StandardMethodCodec::GetInstance());

      channel.SetStreamHandler(std::move(id_token_handler));
  
      result(ErrorOr<std::string>(std::string(name)));
}

 class FlutterAuthStateListener : public firebase::auth::AuthStateListener {
     public:
      void SetEventSink(
          std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>
              event_sink) {
    event_sink_ = std::move(event_sink);
      }

      void OnAuthStateChanged(Auth* auth) override {
    // Generate your ID Token
    firebase::auth::User user = auth->current_user();
    PigeonUserDetails userDetails = FirebaseAuthPlugin::ParseUserDetails(user);

    using flutter::EncodableMap;
    using flutter::EncodableValue;

    if (event_sink_) {
      if (user.is_valid()) {
        event_sink_->Success(EncodableValue(EncodableMap{
            {EncodableValue("user"), userDetails.ToEncodableList()}}));
      } else {
        event_sink_->Success(
            EncodableValue(EncodableMap{{EncodableValue("user"), nullptr}}));
      }
    }
      }

     private:
      std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> event_sink_;
};


class AuthStateStreamHandler
    : public flutter::StreamHandler<flutter::EncodableValue> {
     public:
      AuthStateStreamHandler() { listener_ = nullptr; }

      std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
      OnListenInternal(
          const flutter::EncodableValue* arguments,
          std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events)
          override {
    listener_ = new FlutterAuthStateListener();
    listener_->SetEventSink(std::move(events));
    return nullptr;
      }

      std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
      OnCancelInternal(const flutter::EncodableValue* arguments) override {
    listener_->SetEventSink(nullptr);
    listener_ = nullptr;
    return nullptr;
      }

     private:
      FlutterAuthStateListener* listener_;
};


void FirebaseAuthPlugin::RegisterAuthStateListener(
    const PigeonFirebaseApp& app,
    std::function<void(ErrorOr<std::string> reply)> result) {

      std::string name =
          kFLTFirebaseAuthChannelName + "/auth-state/" + app.app_name();

      auto auth_state_handler = std::make_unique<AuthStateStreamHandler>();

      flutter::EventChannel<flutter::EncodableValue> channel(
          binaryMessenger, name, &flutter::StandardMethodCodec::GetInstance());

      channel.SetStreamHandler(std::move(auth_state_handler));

      result(ErrorOr<std::string>(std::string(name)));
}

void FirebaseAuthPlugin::UseEmulator(
    const PigeonFirebaseApp& app, const std::string& host, int64_t port,
    std::function<void(std::optional<FlutterError> reply)> result) {
  // TODO: C++ function missing
}

void FirebaseAuthPlugin::ApplyActionCode(
    const PigeonFirebaseApp& app, const std::string& code,
    std::function<void(std::optional<FlutterError> reply)> result) {}

void FirebaseAuthPlugin::CheckActionCode(
    const PigeonFirebaseApp& app, const std::string& code,
    std::function<void(ErrorOr<PigeonActionCodeInfo> reply)> result) {
  // TODO: C++ function missing
}

void FirebaseAuthPlugin::ConfirmPasswordReset(
    const PigeonFirebaseApp& app, const std::string& code,
    const std::string& new_password,
    std::function<void(std::optional<FlutterError> reply)> result) {
  // TODO: C++ function missing
}

void FirebaseAuthPlugin::CreateUserWithEmailAndPassword(
    const PigeonFirebaseApp& app, const std::string& email,
    const std::string& password,
    std::function<void(ErrorOr<PigeonUserCredential> reply)> result) {
  firebase::auth::Auth* firebaseAuth = GetAuthFromPigeon(app);


  firebase::Future<firebase::auth::AuthResult> createUserFuture =
      firebaseAuth->CreateUserWithEmailAndPassword(email.c_str(), password.c_str());

  createUserFuture.OnCompletion(
      [result](const firebase::Future<firebase::auth::AuthResult>&
                   completed_future) {
        // We are probably in a different thread right now.
        if (completed_future.error() == 0) {
          PigeonUserCredential credential =
              ParseAuthResult(completed_future.result());
          result(credential);
        } else {
          result(FlutterError(completed_future.error_message()));
        }
      });
}

void FirebaseAuthPlugin::SignInAnonymously(
    const PigeonFirebaseApp& app,
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
   }
   else {
     result(FlutterError(completed_future.error_message()));
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
    flutter::EncodableMap arguments, const PigeonFirebaseApp& app) {
  std::string signInMethod =
      std::get<std::string>(arguments[kArgumentSignInMethod]);
  std::string secret = std::get<std::string>(arguments[kArgumentSecret]);
  std::string idToken = std::get<std::string>(arguments[kArgumentIdToken]);
  std::string accessToken = std::get<std::string>(arguments[kArgumentAccessToken]);
  std::string rawNonce = std::get<std::string>(arguments[kArgumentRawNonce]);


  // Password Auth
  if (signInMethod == kSignInMethodPassword) {
    std::string email = std::get<std::string>(arguments[kArgumentEmail]);
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

  // Facebook Auth
  if (signInMethod == kSignInMethodFacebook) {
    return firebase::auth::FacebookAuthProvider::GetCredential(
        accessToken.c_str());
  }

  // Google Auth
  if (signInMethod == kSignInMethodGoogle) {
    return firebase::auth::GoogleAuthProvider::GetCredential(
        idToken.c_str(), accessToken.c_str());
  }

  // Twitter Auth
  if (signInMethod == kSignInMethodTwitter) {
    return firebase::auth::TwitterAuthProvider::GetCredential(idToken.c_str(),
                                                              secret.c_str());
  }

  // GitHub Auth
  if (signInMethod == kSignInMethodGithub) {
    return firebase::auth::GitHubAuthProvider::GetCredential(
        accessToken.c_str());
  }

  // OAuth
  if (signInMethod == kSignInMethodOAuth) {
    std::string providerId = std::get<std::string>(arguments[kArgumentProviderId]);
    // As of my knowledge cutoff in September 2021, Firebase C++ SDK doesn't
    // support creating OAuthProvider credentials directly
    std::cout << "Creating OAuthProvider credentials directly is not supported "
                 "in Firebase C++ SDK as of September 2021.\n";
    return firebase::auth::Credential();
  }

  // If no known auth method matched
  printf(
      "Support for an auth provider with identifier '%s' is not implemented.\n",
      signInMethod.c_str());
  return firebase::auth::Credential();
}


void FirebaseAuthPlugin::SignInWithCredential(
    const PigeonFirebaseApp& app, const flutter::EncodableMap& input,
    std::function<void(ErrorOr<PigeonUserCredential> reply)> result) {
  firebase::auth::Auth* firebaseAuth = GetAuthFromPigeon(app);


  firebase::Future<firebase::auth::User> signInFuture =
      firebaseAuth->SignInWithCredential(getCredentialFromArguments(input, app));

  signInFuture.OnCompletion(
      [result](const firebase::Future<firebase::auth::User>&
                   completed_future) {
        // We are probably in a different thread right now.
        if (completed_future.error() == 0) {
          // TODO: not the right return type from C++ SDK
          PigeonUserInfo credential =
              ParseUserInfo(completed_future.result());
          //result(credential);
        } else {
          result(FlutterError(completed_future.error_message()));
        }
      });
}

void FirebaseAuthPlugin::SignInWithCustomToken(
    const PigeonFirebaseApp& app, const std::string& token,
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
          result(FlutterError(completed_future.error_message()));
        }
      });
}

void FirebaseAuthPlugin::SignInWithEmailAndPassword(
    const PigeonFirebaseApp& app, const std::string& email,
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
          result(FlutterError(completed_future.error_message()));
        }
      });
}

void FirebaseAuthPlugin::SignInWithEmailLink(
    const PigeonFirebaseApp& app, const std::string& email,
    const std::string& email_link,
    std::function<void(ErrorOr<PigeonUserCredential> reply)> result) {
  // TODO: missing from C++ SDK
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
    const PigeonFirebaseApp& app, const PigeonSignInProvider& sign_in_provider,
    std::function<void(ErrorOr<PigeonUserCredential> reply)> result) {
  firebase::auth::Auth* firebaseAuth = GetAuthFromPigeon(app);

  firebase::Future<firebase::auth::AuthResult> signInFuture =
      firebaseAuth->SignInWithProvider(&getProviderFromArguments(sign_in_provider));

  signInFuture.OnCompletion(
      [result](const firebase::Future<firebase::auth::AuthResult>&
                   completed_future) {
        // We are probably in a different thread right now.
        if (completed_future.error() == 0) {
          PigeonUserCredential credential =
              ParseAuthResult(completed_future.result());
          result(credential);
        } else {
          result(FlutterError(completed_future.error_message()));
        }
      });
}

void FirebaseAuthPlugin::SignOut(
    const PigeonFirebaseApp& app,
    std::function<void(std::optional<FlutterError> reply)> result) {
  firebase::auth::Auth* firebaseAuth = GetAuthFromPigeon(app);

   firebaseAuth->SignOut();
}

flutter::EncodableList TransformStringList(const std::vector<std::string>& string_list) {
   flutter::EncodableList encodable_list;

   for (const auto& value : string_list) {
    encodable_list.push_back(value);
   }

   return encodable_list;
}


void FirebaseAuthPlugin::FetchSignInMethodsForEmail(
    const PigeonFirebaseApp& app, const std::string& email,
    std::function<void(ErrorOr<flutter::EncodableList> reply)> result) {
   firebase::auth::Auth* firebaseAuth = GetAuthFromPigeon(app);

   firebase::Future<firebase::auth::Auth::FetchProvidersResult> signInFuture =
       firebaseAuth->FetchProvidersForEmail(email.c_str()
                                               );

   signInFuture.OnCompletion(
       [result](
           const firebase::Future<firebase::auth::Auth::FetchProvidersResult>&
                    completed_future) {
         // We are probably in a different thread right now.
         if (completed_future.error() == 0) {
           result(TransformStringList(completed_future.result()->providers));
         } else {
           result(FlutterError(completed_future.error_message()));
         }
       });
}

void FirebaseAuthPlugin::SendPasswordResetEmail(
    const PigeonFirebaseApp& app, const std::string& email,
    const PigeonActionCodeSettings* action_code_settings,
    std::function<void(std::optional<FlutterError> reply)> result) {
   firebase::auth::Auth* firebaseAuth = GetAuthFromPigeon(app);

   firebase::Future<void> signInFuture =
       firebaseAuth->SendPasswordResetEmail(email.c_str());

   signInFuture.OnCompletion(
       [result](const firebase::Future<void>&
               completed_future) {
         // We are probably in a different thread right now.
         if (completed_future.error() == 0) {
           result(std::nullopt);
         } else {
           result(FlutterError(completed_future.error_message()));
         }
       });
}

void FirebaseAuthPlugin::SendSignInLinkToEmail(
    const PigeonFirebaseApp& app, const std::string& email,
    const PigeonActionCodeSettings& action_code_settings,
    std::function<void(std::optional<FlutterError> reply)> result) {
  // TODO: missing from C++ SDK
}

void FirebaseAuthPlugin::SetLanguageCode(
    const PigeonFirebaseApp& app, const std::string* language_code,
    std::function<void(ErrorOr<std::string> reply)> result) {
   firebase::auth::Auth* firebaseAuth = GetAuthFromPigeon(app);

    firebaseAuth->set_language_code(language_code->c_str());

    result(*language_code);
}

void FirebaseAuthPlugin::SetSettings(
    const PigeonFirebaseApp& app, const PigeonFirebaseAuthSettings& settings,
    std::function<void(std::optional<FlutterError> reply)> result) {
    // TODO: missing from C++ SDK
}

void FirebaseAuthPlugin::VerifyPasswordResetCode(
    const PigeonFirebaseApp& app, const std::string& code,
    std::function<void(ErrorOr<std::string> reply)> result) {
    // TODO: missing from C++ SDK
}

void FirebaseAuthPlugin::VerifyPhoneNumber(
    const PigeonFirebaseApp& app, const PigeonVerifyPhoneNumberRequest& request,
    std::function<void(ErrorOr<std::string> reply)> result) {
    // TODO: missing from C++ SDK
}

void FirebaseAuthPlugin::Delete(
    const PigeonFirebaseApp& app,
    std::function<void(std::optional<FlutterError> reply)> result) {
    firebase::auth::Auth* firebaseAuth = GetAuthFromPigeon(app);
    firebase::auth::User user = firebaseAuth->current_user();

   firebase::Future<void> future =
        user.Delete();

    future.OnCompletion(
        [result](const firebase::Future<void>& completed_future) {
          // We are probably in a different thread right now.
          if (completed_future.error() == 0) {
            result(std::nullopt);
          } else {
            result(FlutterError(completed_future.error_message()));
          }
        });
}

void FirebaseAuthPlugin::GetIdToken(
    const PigeonFirebaseApp& app, bool force_refresh,
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
            result(FlutterError(completed_future.error_message()));
          }
        });
}

void FirebaseAuthPlugin::LinkWithCredential(
    const PigeonFirebaseApp& app, const flutter::EncodableMap& input,
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
            result(FlutterError(completed_future.error_message()));
          }
        });
}

void FirebaseAuthPlugin::LinkWithProvider(
    const PigeonFirebaseApp& app, const PigeonSignInProvider& sign_in_provider,
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
            result(FlutterError(completed_future.error_message()));
          }
        });
}

void FirebaseAuthPlugin::ReauthenticateWithCredential(
    const PigeonFirebaseApp& app, const flutter::EncodableMap& input,
    std::function<void(ErrorOr<PigeonUserCredential> reply)> result) {
    firebase::auth::Auth* firebaseAuth = GetAuthFromPigeon(app);
    firebase::auth::User user = firebaseAuth->current_user();

    firebase::Future<void> future =
        user.Reauthenticate(getCredentialFromArguments(input, app));

    future.OnCompletion(
        [result](const firebase::Future<void>&
                     completed_future) {
          // We are probably in a different thread right now.
          if (completed_future.error() == 0) {
            // TODO: wrong return type
          } else {
            result(FlutterError(completed_future.error_message()));
          }
        });
}

void FirebaseAuthPlugin::ReauthenticateWithProvider(
    const PigeonFirebaseApp& app, const PigeonSignInProvider& sign_in_provider,
    std::function<void(ErrorOr<PigeonUserCredential> reply)> result) {
    firebase::auth::Auth* firebaseAuth = GetAuthFromPigeon(app);
    firebase::auth::User user = firebaseAuth->current_user();

    firebase::Future<firebase::auth::AuthResult> future =
        user.ReauthenticateWithProvider(&getProviderFromArguments(sign_in_provider));

    future.OnCompletion(
        [result](const firebase::Future<firebase::auth::AuthResult>&
                     completed_future) {
          // We are probably in a different thread right now.
          if (completed_future.error() == 0) {
            PigeonUserCredential credential =
                ParseAuthResult(completed_future.result());
            result(credential);
          } else {
            result(FlutterError(completed_future.error_message()));
          }
        });
}

void FirebaseAuthPlugin::Reload(
    const PigeonFirebaseApp& app,
    std::function<void(ErrorOr<PigeonUserDetails> reply)> result) {
    firebase::auth::Auth* firebaseAuth = GetAuthFromPigeon(app);
    firebase::auth::User user = firebaseAuth->current_user();

    firebase::Future<void> future =
        user.Reload(
            );

    future.OnCompletion(
        [result, firebaseAuth](const firebase::Future<void>&
                     completed_future) {
          // We are probably in a different thread right now.
          if (completed_future.error() == 0) {
            PigeonUserDetails user =
                ParseUserDetails(firebaseAuth->current_user());
            result(user);
          } else {
            result(FlutterError(completed_future.error_message()));
          }
        });
}

void FirebaseAuthPlugin::SendEmailVerification(
    const PigeonFirebaseApp& app,
    const PigeonActionCodeSettings* action_code_settings,
    std::function<void(std::optional<FlutterError> reply)> result) {
    firebase::auth::Auth* firebaseAuth = GetAuthFromPigeon(app);
    firebase::auth::User user = firebaseAuth->current_user();

    firebase::Future<void> future = user.SendEmailVerification();

    future.OnCompletion([result](
                            const firebase::Future<void>& completed_future) {
      // We are probably in a different thread right now.
      if (completed_future.error() == 0) {
        result(std::nullopt);
      } else {
        result(FlutterError(completed_future.error_message()));
      }
    });
}

void FirebaseAuthPlugin::Unlink(
    const PigeonFirebaseApp& app, const std::string& provider_id,
    std::function<void(ErrorOr<PigeonUserCredential> reply)> result) {
    firebase::auth::Auth* firebaseAuth = GetAuthFromPigeon(app);
    firebase::auth::User user = firebaseAuth->current_user();

    firebase::Future<firebase::auth::AuthResult> future = user.Unlink(provider_id.c_str());

    future.OnCompletion(
        [result](const firebase::Future<firebase::auth::AuthResult>&
                     completed_future) {
          // We are probably in a different thread right now.
          if (completed_future.error() == 0) {
            PigeonUserCredential credential =
                ParseAuthResult(completed_future.result());
            result(credential);
          } else {
            result(FlutterError(completed_future.error_message()));
          }
        });
}

void FirebaseAuthPlugin::UpdateEmail(
    const PigeonFirebaseApp& app, const std::string& new_email,
    std::function<void(ErrorOr<PigeonUserDetails> reply)> result) {
    firebase::auth::Auth* firebaseAuth = GetAuthFromPigeon(app);
    firebase::auth::User user = firebaseAuth->current_user();

    firebase::Future<void> future = user.UpdateEmail(new_email.c_str());

    future.OnCompletion([result, firebaseAuth](
                            const firebase::Future<void>& completed_future) {
      // We are probably in a different thread right now.
      if (completed_future.error() == 0) {
        PigeonUserDetails user = ParseUserDetails(firebaseAuth->current_user());
        result(user);
      } else {
        result(FlutterError(completed_future.error_message()));
      }
    });
}

void FirebaseAuthPlugin::UpdatePassword(
    const PigeonFirebaseApp& app, const std::string& new_password,
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
        result(FlutterError(completed_future.error_message()));
      }
    });
}

firebase::auth::PhoneAuthCredential getPhoneCredentialFromArguments(
    flutter::EncodableMap arguments, const PigeonFirebaseApp& app) {
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
    const PigeonFirebaseApp& app, const flutter::EncodableMap& input,
    std::function<void(ErrorOr<PigeonUserDetails> reply)> result) {
    firebase::auth::Auth* firebaseAuth = GetAuthFromPigeon(app);
    firebase::auth::User user = firebaseAuth->current_user();

    firebase::Future<firebase::auth::User> future =
        user.UpdatePhoneNumberCredential(
            getPhoneCredentialFromArguments(input, app));

    future.OnCompletion([result](
            const firebase::Future<firebase::auth::User>& completed_future) {
      // We are probably in a different thread right now.
      if (completed_future.error() == 0) {
        PigeonUserDetails user = ParseUserDetails(*completed_future.result());
        result(user);
      } else {
        result(FlutterError(completed_future.error_message()));
      }
    });
}

void FirebaseAuthPlugin::UpdateProfile(
    const PigeonFirebaseApp& app, const PigeonUserProfile& profile,
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

    firebase::Future<void> future =
        user.UpdateUserProfile(userProfile);

    future.OnCompletion(
        [result, firebaseAuth](
            const firebase::Future<void>& completed_future) {
          // We are probably in a different thread right now.
          if (completed_future.error() == 0) {
            PigeonUserDetails user =
                ParseUserDetails(firebaseAuth->current_user());
            result(user);
          } else {
            result(FlutterError(completed_future.error_message()));
          }
        });
}

void FirebaseAuthPlugin::VerifyBeforeUpdateEmail(
    const PigeonFirebaseApp& app, const std::string& new_email,
    const PigeonActionCodeSettings* action_code_settings,
    std::function<void(std::optional<FlutterError> reply)> result) {
  // TODO: missing function
}


}  // namespace firebase_auth
