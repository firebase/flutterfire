// Copyright 2025, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "include/firebase_auth/firebase_auth_plugin.h"

#include <flutter_linux/flutter_linux.h>

#include <cstdint>
#include <functional>
#include <map>
#include <string>
#include <unordered_map>
#include <vector>

#include "firebase/app.h"
#include "firebase/auth.h"
#include "firebase/future.h"
#include "firebase/log.h"
#include "firebase/util.h"
#include "firebase/variant.h"
#include "firebase_auth/plugin_version.h"
#include "firebase_core/firebase_core_plugin.h"
#include "firebase_core/flutter_firebase_plugin.h"
#include "messages.g.h"

using ::firebase::App;
using ::firebase::auth::Auth;
using ::firebase::auth::AuthError;

static const char kLibraryName[] = "flutter-fire-auth";
static const char kFLTFirebaseAuthChannelName[] = "firebase_auth_plugin";

#define FIREBASE_AUTH_PLUGIN(obj)                                     \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), firebase_auth_plugin_get_type(), \
                              FirebaseAuthPlugin))

struct _FirebaseAuthPlugin {
  GObject parent_instance;
};

G_DEFINE_TYPE(FirebaseAuthPlugin, firebase_auth_plugin, g_object_get_type())

// The messenger is kept for the lifetime of the engine, mirroring the static
// binaryMessenger member of the Windows implementation.
static FlBinaryMessenger* g_binary_messenger = nullptr;

// Runs a std::function on the main (GLib) thread. Firebase C++ futures
// complete on SDK worker threads, but the Flutter Linux embedder requires all
// messenger/event-channel calls to happen on the platform thread.
static gboolean RunOnMainThreadCb(gpointer user_data) {
  auto* function = static_cast<std::function<void()>*>(user_data);
  (*function)();
  delete function;
  return G_SOURCE_REMOVE;
}

static void PostToMainThread(std::function<void()> function) {
  g_idle_add(RunOnMainThreadCb, new std::function<void()>(std::move(function)));
}

static Auth* GetAuthFromPigeon(FirebaseAuthAuthPigeonFirebaseApp* pigeon_app) {
  App* app =
      App::GetInstance(firebase_auth_auth_pigeon_firebase_app_get_app_name(pigeon_app));
  return Auth::GetAuth(app);
}

static std::string GetAuthErrorCode(AuthError auth_error) {
  switch (auth_error) {
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

// Converts a firebase::Variant map into an FlValue map.
// Ownership: returns a new reference (transfer full).
static FlValue* ConvertToFlValue(const firebase::Variant& variant);

static FlValue* ConvertToFlValueMap(
    const std::map<firebase::Variant, firebase::Variant>& original_map) {
  FlValue* converted_map = fl_value_new_map();
  for (const auto& kv : original_map) {
    fl_value_set_take(converted_map, ConvertToFlValue(kv.first),
                      ConvertToFlValue(kv.second));
  }
  return converted_map;
}

// Converts a firebase::Variant to an FlValue.
// Ownership: returns a new reference (transfer full).
static FlValue* ConvertToFlValue(const firebase::Variant& variant) {
  switch (variant.type()) {
    case firebase::Variant::kTypeNull:
      return fl_value_new_null();
    case firebase::Variant::kTypeInt64:
      return fl_value_new_int(variant.int64_value());
    case firebase::Variant::kTypeDouble:
      return fl_value_new_float(variant.double_value());
    case firebase::Variant::kTypeBool:
      return fl_value_new_bool(variant.bool_value());
    case firebase::Variant::kTypeStaticString:
      return fl_value_new_string(variant.string_value());
    case firebase::Variant::kTypeMutableString:
      return fl_value_new_string(variant.mutable_string().c_str());
    case firebase::Variant::kTypeMap:
      return ConvertToFlValueMap(variant.map());
    case firebase::Variant::kTypeStaticBlob:
    case firebase::Variant::kTypeMutableBlob:
      return fl_value_new_uint8_list(variant.blob_data(), variant.blob_size());
    default:
      return fl_value_new_null();
  }
}

// Converts a firebase user to the pigeon InternalUserInfo type.
// Ownership: returns a new reference (transfer full).
static FirebaseAuthInternalUserInfo* ParseUserInfo(
    const firebase::auth::User& user) {
  int64_t creation_timestamp = user.metadata().creation_timestamp;
  int64_t last_sign_in_timestamp = user.metadata().last_sign_in_timestamp;
  return firebase_auth_internal_user_info_new(
      user.uid().c_str(), user.email().c_str(), user.display_name().c_str(),
      user.photo_url().c_str(), user.phone_number().c_str(),
      user.is_anonymous(), user.is_email_verified(), user.provider_id().c_str(),
      /* tenant_id= */ nullptr, /* refresh_token= */ nullptr,
      &creation_timestamp, &last_sign_in_timestamp);
}

// Converts a provider user info entry to an FlValue map.
// Ownership: returns a new reference (transfer full).
static FlValue* ParseUserInfoToMap(
    const firebase::auth::UserInfoInterface& user_info) {
  FlValue* map = fl_value_new_map();
  fl_value_set_take(map, fl_value_new_string("displayName"),
                    fl_value_new_string(user_info.display_name().c_str()));
  fl_value_set_take(map, fl_value_new_string("email"),
                    fl_value_new_string(user_info.email().c_str()));
  fl_value_set_take(map, fl_value_new_string("isEmailVerified"),
                    fl_value_new_bool(TRUE));
  fl_value_set_take(map, fl_value_new_string("phoneNumber"),
                    fl_value_new_string(user_info.phone_number().c_str()));
  fl_value_set_take(map, fl_value_new_string("photoUrl"),
                    fl_value_new_string(user_info.photo_url().c_str()));
  fl_value_set_take(map, fl_value_new_string("uid"),
                    fl_value_new_string(user_info.uid().c_str()));
  fl_value_set_take(map, fl_value_new_string("providerId"),
                    fl_value_new_string(user_info.provider_id().c_str()));
  fl_value_set_take(map, fl_value_new_string("isAnonymous"),
                    fl_value_new_bool(FALSE));
  return map;
}

// Converts the provider data of a user to an FlValue list of maps.
// Ownership: returns a new reference (transfer full).
static FlValue* ParseProviderData(const firebase::auth::User& user) {
  FlValue* output = fl_value_new_list();
  for (const firebase::auth::UserInfoInterface& user_info :
       user.provider_data()) {
    fl_value_append_take(output, ParseUserInfoToMap(user_info));
  }
  return output;
}

// Converts a firebase user to the pigeon InternalUserDetails type.
// Ownership: returns a new reference (transfer full).
static FirebaseAuthInternalUserDetails* ParseUserDetails(
    const firebase::auth::User& user) {
  g_autoptr(FirebaseAuthInternalUserInfo) user_info = ParseUserInfo(user);
  g_autoptr(FlValue) provider_data = ParseProviderData(user);
  return firebase_auth_internal_user_details_new(user_info, provider_data);
}

// Converts firebase AdditionalUserInfo to the pigeon type.
// Ownership: returns a new reference (transfer full).
static FirebaseAuthInternalAdditionalUserInfo* ParseAdditionalUserInfo(
    const firebase::auth::AdditionalUserInfo& additional_user_info) {
  g_autoptr(FlValue) profile = ConvertToFlValueMap(additional_user_info.profile);
  // Cannot know if the user is new or not with current API.
  return firebase_auth_internal_additional_user_info_new(
      /* is_new_user= */ FALSE, additional_user_info.provider_id.c_str(),
      additional_user_info.user_name.c_str(),
      /* authorization_code= */ nullptr, profile);
}

// Converts a firebase AuthResult to the pigeon InternalUserCredential type.
// Ownership: returns a new reference (transfer full).
static FirebaseAuthInternalUserCredential* ParseAuthResult(
    const firebase::auth::AuthResult* auth_result) {
  g_autoptr(FirebaseAuthInternalUserDetails) user =
      ParseUserDetails(auth_result->user);
  g_autoptr(FirebaseAuthInternalAdditionalUserInfo) additional_user_info =
      ParseAdditionalUserInfo(auth_result->additional_user_info);
  return firebase_auth_internal_user_credential_new(user, additional_user_info,
                                                    /* credential= */ nullptr);
}

// Generic helpers to complete pigeon responses from firebase futures.
//
// The response handle is referenced for the duration of the asynchronous
// operation and released on the main thread after responding. `Handle` is one
// of the pigeon *ResponseHandle GObject types.

template <typename Handle>
using ErrorRespondFn = void (*)(Handle*, const gchar*, const gchar*, FlValue*);

template <typename Handle>
static void RespondFutureError(const firebase::FutureBase& completed_future,
                               Handle* response_handle,
                               ErrorRespondFn<Handle> respond_error) {
  std::string code =
      GetAuthErrorCode(static_cast<AuthError>(completed_future.error()));
  std::string message = completed_future.error_message() != nullptr
                            ? completed_future.error_message()
                            : "";
  PostToMainThread([response_handle, respond_error, code, message]() {
    respond_error(response_handle, code.c_str(), message.c_str(), nullptr);
    g_object_unref(response_handle);
  });
}

// Completes a Future<void> with an empty pigeon response.
template <typename Handle>
static void CompleteVoidFuture(firebase::Future<void> future,
                               Handle* response_handle,
                               void (*respond)(Handle*),
                               ErrorRespondFn<Handle> respond_error) {
  g_object_ref(response_handle);
  future.OnCompletion([response_handle, respond, respond_error](
                          const firebase::Future<void>& completed_future) {
    // We are probably in a different thread right now.
    if (completed_future.error() == 0) {
      PostToMainThread([response_handle, respond]() {
        respond(response_handle);
        g_object_unref(response_handle);
      });
    } else {
      RespondFutureError(completed_future, response_handle, respond_error);
    }
  });
}

// Completes a Future<AuthResult> with an InternalUserCredential response.
template <typename Handle>
static void CompleteAuthResultFuture(
    firebase::Future<firebase::auth::AuthResult> future,
    Handle* response_handle,
    void (*respond)(Handle*, FirebaseAuthInternalUserCredential*),
    ErrorRespondFn<Handle> respond_error) {
  g_object_ref(response_handle);
  future.OnCompletion(
      [response_handle, respond, respond_error](
          const firebase::Future<firebase::auth::AuthResult>&
              completed_future) {
        // We are probably in a different thread right now.
        if (completed_future.error() == 0) {
          FirebaseAuthInternalUserCredential* credential =
              ParseAuthResult(completed_future.result());
          PostToMainThread([response_handle, respond, credential]() {
            respond(response_handle, credential);
            g_object_unref(credential);
            g_object_unref(response_handle);
          });
        } else {
          RespondFutureError(completed_future, response_handle, respond_error);
        }
      });
}

// Completes a Future<void> with an InternalUserDetails response built from the
// current user of the given auth instance.
template <typename Handle>
static void CompleteUserDetailsFuture(
    firebase::Future<void> future, Auth* firebase_auth,
    Handle* response_handle,
    void (*respond)(Handle*, FirebaseAuthInternalUserDetails*),
    ErrorRespondFn<Handle> respond_error) {
  g_object_ref(response_handle);
  future.OnCompletion(
      [response_handle, firebase_auth, respond, respond_error](
          const firebase::Future<void>& completed_future) {
        // We are probably in a different thread right now.
        if (completed_future.error() == 0) {
          FirebaseAuthInternalUserDetails* user =
              ParseUserDetails(firebase_auth->current_user());
          PostToMainThread([response_handle, respond, user]() {
            respond(response_handle, user);
            g_object_unref(user);
            g_object_unref(response_handle);
          });
        } else {
          RespondFutureError(completed_future, response_handle, respond_error);
        }
      });
}

// Event channels (auth-state / id-token).

// Builds the event payload sent on the auth-state and id-token event
// channels: {"user": [userInfoFieldList, providerData]} or {"user": null}.
// The user info field list mirrors the pigeon encoding of InternalUserInfo
// (fields in declaration order), which is what the Dart side decodes with
// InternalUserInfo.decode().
// Ownership: returns a new reference (transfer full).
static FlValue* BuildUserEventPayload(Auth* auth) {
  firebase::auth::User user = auth->current_user();

  FlValue* event = fl_value_new_map();
  if (user.is_valid()) {
    FlValue* user_info_list = fl_value_new_list();
    fl_value_append_take(user_info_list,
                         fl_value_new_string(user.uid().c_str()));
    fl_value_append_take(user_info_list,
                         fl_value_new_string(user.email().c_str()));
    fl_value_append_take(user_info_list,
                         fl_value_new_string(user.display_name().c_str()));
    fl_value_append_take(user_info_list,
                         fl_value_new_string(user.photo_url().c_str()));
    fl_value_append_take(user_info_list,
                         fl_value_new_string(user.phone_number().c_str()));
    fl_value_append_take(user_info_list, fl_value_new_bool(user.is_anonymous()));
    fl_value_append_take(user_info_list,
                         fl_value_new_bool(user.is_email_verified()));
    fl_value_append_take(user_info_list,
                         fl_value_new_string(user.provider_id().c_str()));
    fl_value_append_take(user_info_list, fl_value_new_null());  // tenantId
    fl_value_append_take(user_info_list, fl_value_new_null());  // refreshToken
    fl_value_append_take(
        user_info_list,
        fl_value_new_int(user.metadata().creation_timestamp));
    fl_value_append_take(
        user_info_list,
        fl_value_new_int(user.metadata().last_sign_in_timestamp));

    FlValue* user_details = fl_value_new_list();
    fl_value_append_take(user_details, user_info_list);
    fl_value_append_take(user_details, ParseProviderData(user));
    fl_value_set_take(event, fl_value_new_string("user"), user_details);
  } else {
    fl_value_set_take(event, fl_value_new_string("user"), fl_value_new_null());
  }
  return event;
}

struct AuthEventChannel;

class FlutterIdTokenListener : public firebase::auth::IdTokenListener {
 public:
  explicit FlutterIdTokenListener(AuthEventChannel* channel)
      : channel_(channel) {}
  void OnIdTokenChanged(Auth* auth) override;

 private:
  AuthEventChannel* channel_;
};

class FlutterAuthStateListener : public firebase::auth::AuthStateListener {
 public:
  explicit FlutterAuthStateListener(AuthEventChannel* channel)
      : channel_(channel) {}
  void OnAuthStateChanged(Auth* auth) override;

 private:
  AuthEventChannel* channel_;
};

// State for one auth event channel. Channels are created on demand per app
// (and kind) and kept for the lifetime of the process, mirroring the Windows
// implementation which never destroys its event channels.
struct AuthEventChannel {
  FlEventChannel* channel = nullptr;  // owned
  // The messenger the channel was created on. Identifies the owning engine so
  // a cached channel is not reused after the engine (and its messenger) has
  // been recreated.
  FlBinaryMessenger* messenger = nullptr;  // weak
  Auth* auth = nullptr;
  bool is_id_token_channel = false;
  FlutterIdTokenListener* id_token_listener = nullptr;
  FlutterAuthStateListener* auth_state_listener = nullptr;
};

static void SendAuthEvent(AuthEventChannel* event_channel, Auth* auth) {
  FlValue* event = BuildUserEventPayload(auth);
  PostToMainThread([event_channel, event]() {
    fl_event_channel_send(event_channel->channel, event, nullptr, nullptr);
    fl_value_unref(event);
  });
}

void FlutterIdTokenListener::OnIdTokenChanged(Auth* auth) {
  SendAuthEvent(channel_, auth);
}

void FlutterAuthStateListener::OnAuthStateChanged(Auth* auth) {
  SendAuthEvent(channel_, auth);
}

static FlMethodErrorResponse* AuthEventChannelListenCb(FlEventChannel* channel,
                                                       FlValue* args,
                                                       gpointer user_data) {
  auto* event_channel = static_cast<AuthEventChannel*>(user_data);
  if (event_channel->is_id_token_channel) {
    if (event_channel->id_token_listener == nullptr) {
      event_channel->id_token_listener =
          new FlutterIdTokenListener(event_channel);
      event_channel->auth->AddIdTokenListener(
          event_channel->id_token_listener);
    }
  } else {
    if (event_channel->auth_state_listener == nullptr) {
      event_channel->auth_state_listener =
          new FlutterAuthStateListener(event_channel);
      event_channel->auth->AddAuthStateListener(
          event_channel->auth_state_listener);
    }
  }
  return nullptr;
}

static FlMethodErrorResponse* AuthEventChannelCancelCb(FlEventChannel* channel,
                                                       FlValue* args,
                                                       gpointer user_data) {
  auto* event_channel = static_cast<AuthEventChannel*>(user_data);
  if (event_channel->id_token_listener != nullptr) {
    event_channel->auth->RemoveIdTokenListener(
        event_channel->id_token_listener);
    delete event_channel->id_token_listener;
    event_channel->id_token_listener = nullptr;
  }
  if (event_channel->auth_state_listener != nullptr) {
    event_channel->auth->RemoveAuthStateListener(
        event_channel->auth_state_listener);
    delete event_channel->auth_state_listener;
    event_channel->auth_state_listener = nullptr;
  }
  return nullptr;
}

// Creates (or reuses) the event channel with the given name and returns its
// name. The channel and its state are intentionally kept alive for the
// process lifetime, like on Windows.
static std::string SetupAuthEventChannel(Auth* auth, const std::string& name,
                                         bool is_id_token_channel) {
  static std::unordered_map<std::string, AuthEventChannel*>* channels =
      new std::unordered_map<std::string, AuthEventChannel*>();

  auto existing = channels->find(name);
  if (existing != channels->end()) {
    if (existing->second->messenger == g_binary_messenger) {
      return name;
    }
    // The engine was recreated: the cached channel is bound to the previous
    // messenger and can no longer reach Dart. Detach its SDK listeners and
    // build a fresh channel on the current messenger (mirroring Windows,
    // which rebinds the event channel on every registration call). The stale
    // struct and FlEventChannel are intentionally leaked because queued
    // main-thread events may still reference them.
    AuthEventChannel* stale = existing->second;
    if (stale->id_token_listener != nullptr) {
      stale->auth->RemoveIdTokenListener(stale->id_token_listener);
      stale->id_token_listener = nullptr;
    }
    if (stale->auth_state_listener != nullptr) {
      stale->auth->RemoveAuthStateListener(stale->auth_state_listener);
      stale->auth_state_listener = nullptr;
    }
    channels->erase(existing);
  }

  auto* event_channel = new AuthEventChannel();
  event_channel->messenger = g_binary_messenger;
  event_channel->auth = auth;
  event_channel->is_id_token_channel = is_id_token_channel;

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  event_channel->channel = fl_event_channel_new(g_binary_messenger,
                                                name.c_str(),
                                                FL_METHOD_CODEC(codec));
  fl_event_channel_set_stream_handlers(event_channel->channel,
                                       AuthEventChannelListenCb,
                                       AuthEventChannelCancelCb, event_channel,
                                       nullptr);

  (*channels)[name] = event_channel;
  return name;
}

// Credential helpers.

// Provider type keys.
static const char kSignInMethodPassword[] = "password";
static const char kSignInMethodEmailLink[] = "emailLink";
static const char kSignInMethodFacebook[] = "facebook.com";
static const char kSignInMethodGoogle[] = "google.com";
static const char kSignInMethodTwitter[] = "twitter.com";
static const char kSignInMethodGithub[] = "github.com";
static const char kSignInMethodOAuth[] = "oauth";

// Credential argument keys.
static const char kArgumentProviderId[] = "providerId";
static const char kArgumentSignInMethod[] = "signInMethod";
static const char kArgumentSecret[] = "secret";
static const char kArgumentIdToken[] = "idToken";
static const char kArgumentAccessToken[] = "accessToken";
static const char kArgumentRawNonce[] = "rawNonce";
static const char kArgumentEmail[] = "email";

// Looks up a string value in an FlValue map; returns nullptr when absent or
// not a string (the equivalent of the optional extraction on Windows).
static const gchar* MapLookupString(FlValue* map, const char* key) {
  FlValue* value = fl_value_lookup_string(map, key);
  if (value != nullptr && fl_value_get_type(value) == FL_VALUE_TYPE_STRING) {
    return fl_value_get_string(value);
  }
  return nullptr;
}

static firebase::auth::Credential GetCredentialFromArguments(
    FlValue* arguments) {
  const gchar* sign_in_method_value =
      MapLookupString(arguments, kArgumentSignInMethod);
  if (sign_in_method_value == nullptr) {
    return firebase::auth::Credential();
  }
  std::string sign_in_method = sign_in_method_value;

  // Password Auth
  if (sign_in_method == kSignInMethodPassword) {
    const gchar* email = MapLookupString(arguments, kArgumentEmail);
    const gchar* secret = MapLookupString(arguments, kArgumentSecret);
    return firebase::auth::EmailAuthProvider::GetCredential(email, secret);
  }

  // Email Link Auth
  if (sign_in_method == kSignInMethodEmailLink) {
    // Firebase C++ SDK doesn't have email link authentication.
    g_warning(
        "Email link authentication is not supported in the Firebase C++ "
        "SDK.");
    return firebase::auth::Credential();
  }

  const gchar* id_token = MapLookupString(arguments, kArgumentIdToken);
  const gchar* access_token = MapLookupString(arguments, kArgumentAccessToken);

  // Facebook Auth
  if (sign_in_method == kSignInMethodFacebook) {
    return firebase::auth::FacebookAuthProvider::GetCredential(access_token);
  }

  // Google Auth
  if (sign_in_method == kSignInMethodGoogle) {
    // Both accessToken and idToken arguments can be null. You can use one or
    // the other
    return firebase::auth::GoogleAuthProvider::GetCredential(id_token,
                                                             access_token);
  }

  // Twitter Auth
  if (sign_in_method == kSignInMethodTwitter) {
    const gchar* secret = MapLookupString(arguments, kArgumentSecret);
    return firebase::auth::TwitterAuthProvider::GetCredential(id_token, secret);
  }

  // GitHub Auth
  if (sign_in_method == kSignInMethodGithub) {
    return firebase::auth::GitHubAuthProvider::GetCredential(access_token);
  }

  // OAuth
  if (sign_in_method == kSignInMethodOAuth) {
    const gchar* provider_id = MapLookupString(arguments, kArgumentProviderId);
    const gchar* raw_nonce = MapLookupString(arguments, kArgumentRawNonce);
    // If rawNonce provided use corresponding credential builder
    // e.g. AppleID auth through the webView
    if (raw_nonce != nullptr) {
      return firebase::auth::OAuthProvider::GetCredential(
          provider_id, id_token, raw_nonce, access_token);
    } else {
      return firebase::auth::OAuthProvider::GetCredential(
          provider_id, id_token, access_token);
    }
  }

  // If no known auth method matched
  g_warning(
      "Support for an auth provider with identifier '%s' is not implemented.",
      sign_in_method.c_str());
  return firebase::auth::Credential();
}

static std::vector<std::string> TransformFlValueList(FlValue* fl_list) {
  std::vector<std::string> transformed_list;
  if (fl_list == nullptr || fl_value_get_type(fl_list) != FL_VALUE_TYPE_LIST) {
    return transformed_list;
  }
  size_t length = fl_value_get_length(fl_list);
  for (size_t i = 0; i < length; ++i) {
    FlValue* value = fl_value_get_list_value(fl_list, i);
    if (fl_value_get_type(value) == FL_VALUE_TYPE_STRING) {
      transformed_list.push_back(fl_value_get_string(value));
    }
  }
  return transformed_list;
}

static std::map<std::string, std::string> TransformFlValueMap(
    FlValue* fl_map) {
  std::map<std::string, std::string> transformed_map;
  if (fl_map == nullptr || fl_value_get_type(fl_map) != FL_VALUE_TYPE_MAP) {
    return transformed_map;
  }
  size_t length = fl_value_get_length(fl_map);
  for (size_t i = 0; i < length; ++i) {
    FlValue* key = fl_value_get_map_key(fl_map, i);
    FlValue* value = fl_value_get_map_value(fl_map, i);
    if (fl_value_get_type(key) == FL_VALUE_TYPE_STRING &&
        fl_value_get_type(value) == FL_VALUE_TYPE_STRING) {
      transformed_map[fl_value_get_string(key)] = fl_value_get_string(value);
    }
  }
  return transformed_map;
}

static firebase::auth::FederatedOAuthProviderData GetProviderDataFromArguments(
    FirebaseAuthInternalSignInProvider* sign_in_provider) {
  return firebase::auth::FederatedOAuthProviderData(
      firebase_auth_internal_sign_in_provider_get_provider_id(
          sign_in_provider),
      TransformFlValueList(
          firebase_auth_internal_sign_in_provider_get_scopes(
              sign_in_provider)),
      TransformFlValueMap(
          firebase_auth_internal_sign_in_provider_get_custom_parameters(
              sign_in_provider)));
}

// FirebaseAuthHostApi implementation.

static void HandleRegisterIdTokenListener(
    FirebaseAuthAuthPigeonFirebaseApp* app,
    FirebaseAuthFirebaseAuthHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Auth* firebase_auth = GetAuthFromPigeon(app);
  std::string name = std::string(kFLTFirebaseAuthChannelName) + "/id-token/" +
                     firebase_auth_auth_pigeon_firebase_app_get_app_name(app);
  SetupAuthEventChannel(firebase_auth, name, /* is_id_token_channel= */ true);
  firebase_auth_firebase_auth_host_api_respond_register_id_token_listener(
      response_handle, name.c_str());
}

static void HandleRegisterAuthStateListener(
    FirebaseAuthAuthPigeonFirebaseApp* app,
    FirebaseAuthFirebaseAuthHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Auth* firebase_auth = GetAuthFromPigeon(app);
  std::string name = std::string(kFLTFirebaseAuthChannelName) + "/auth-state/" +
                     firebase_auth_auth_pigeon_firebase_app_get_app_name(app);
  SetupAuthEventChannel(firebase_auth, name, /* is_id_token_channel= */ false);
  firebase_auth_firebase_auth_host_api_respond_register_auth_state_listener(
      response_handle, name.c_str());
}

static void HandleUseEmulator(
    FirebaseAuthAuthPigeonFirebaseApp* app, const gchar* host, int64_t port,
    FirebaseAuthFirebaseAuthHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Auth* firebase_auth = GetAuthFromPigeon(app);
  firebase_auth->UseEmulator(host, static_cast<uint32_t>(port));
  firebase_auth_firebase_auth_host_api_respond_use_emulator(response_handle);
}

static void HandleApplyActionCode(
    FirebaseAuthAuthPigeonFirebaseApp* app, const gchar* code,
    FirebaseAuthFirebaseAuthHostApiResponseHandle* response_handle,
    gpointer user_data) {
  firebase_auth_firebase_auth_host_api_respond_error_apply_action_code(
      response_handle, "unimplemented",
      "ApplyActionCode is not available on this platform yet.", nullptr);
}

static void HandleCheckActionCode(
    FirebaseAuthAuthPigeonFirebaseApp* app, const gchar* code,
    FirebaseAuthFirebaseAuthHostApiResponseHandle* response_handle,
    gpointer user_data) {
  firebase_auth_firebase_auth_host_api_respond_error_check_action_code(
      response_handle, "unimplemented",
      "CheckActionCode is not available on this platform yet.", nullptr);
}

static void HandleConfirmPasswordReset(
    FirebaseAuthAuthPigeonFirebaseApp* app, const gchar* code,
    const gchar* new_password,
    FirebaseAuthFirebaseAuthHostApiResponseHandle* response_handle,
    gpointer user_data) {
  firebase_auth_firebase_auth_host_api_respond_error_confirm_password_reset(
      response_handle, "unimplemented",
      "ConfirmPasswordReset is not available on this platform yet.", nullptr);
}

static void HandleCreateUserWithEmailAndPassword(
    FirebaseAuthAuthPigeonFirebaseApp* app, const gchar* email,
    const gchar* password,
    FirebaseAuthFirebaseAuthHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Auth* firebase_auth = GetAuthFromPigeon(app);
  CompleteAuthResultFuture(
      firebase_auth->CreateUserWithEmailAndPassword(email, password),
      response_handle,
      firebase_auth_firebase_auth_host_api_respond_create_user_with_email_and_password,
      firebase_auth_firebase_auth_host_api_respond_error_create_user_with_email_and_password);
}

static void HandleSignInAnonymously(
    FirebaseAuthAuthPigeonFirebaseApp* app,
    FirebaseAuthFirebaseAuthHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Auth* firebase_auth = GetAuthFromPigeon(app);
  CompleteAuthResultFuture(
      firebase_auth->SignInAnonymously(), response_handle,
      firebase_auth_firebase_auth_host_api_respond_sign_in_anonymously,
      firebase_auth_firebase_auth_host_api_respond_error_sign_in_anonymously);
}

static void HandleSignInWithCredential(
    FirebaseAuthAuthPigeonFirebaseApp* app, FlValue* input,
    FirebaseAuthFirebaseAuthHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Auth* firebase_auth = GetAuthFromPigeon(app);

  firebase::Future<firebase::auth::User> sign_in_future =
      firebase_auth->SignInWithCredential(GetCredentialFromArguments(input));

  g_object_ref(response_handle);
  sign_in_future.OnCompletion(
      [response_handle](
          const firebase::Future<firebase::auth::User>& completed_future) {
        // We are probably in a different thread right now.
        if (completed_future.error() == 0) {
          // TODO: not the right return type from C++ SDK
          g_autoptr(FirebaseAuthInternalUserInfo) user_info =
              ParseUserInfo(*completed_future.result());
          g_autoptr(FlValue) provider_data = fl_value_new_list();
          g_autoptr(FirebaseAuthInternalUserDetails) user =
              firebase_auth_internal_user_details_new(user_info, provider_data);
          FirebaseAuthInternalUserCredential* user_credential =
              firebase_auth_internal_user_credential_new(
                  user, /* additional_user_info= */ nullptr,
                  /* credential= */ nullptr);
          PostToMainThread([response_handle, user_credential]() {
            firebase_auth_firebase_auth_host_api_respond_sign_in_with_credential(
                response_handle, user_credential);
            g_object_unref(user_credential);
            g_object_unref(response_handle);
          });
        } else {
          RespondFutureError(
              completed_future, response_handle,
              firebase_auth_firebase_auth_host_api_respond_error_sign_in_with_credential);
        }
      });
}

static void HandleSignInWithCustomToken(
    FirebaseAuthAuthPigeonFirebaseApp* app, const gchar* token,
    FirebaseAuthFirebaseAuthHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Auth* firebase_auth = GetAuthFromPigeon(app);
  CompleteAuthResultFuture(
      firebase_auth->SignInWithCustomToken(token), response_handle,
      firebase_auth_firebase_auth_host_api_respond_sign_in_with_custom_token,
      firebase_auth_firebase_auth_host_api_respond_error_sign_in_with_custom_token);
}

static void HandleSignInWithEmailAndPassword(
    FirebaseAuthAuthPigeonFirebaseApp* app, const gchar* email,
    const gchar* password,
    FirebaseAuthFirebaseAuthHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Auth* firebase_auth = GetAuthFromPigeon(app);
  CompleteAuthResultFuture(
      firebase_auth->SignInWithEmailAndPassword(email, password),
      response_handle,
      firebase_auth_firebase_auth_host_api_respond_sign_in_with_email_and_password,
      firebase_auth_firebase_auth_host_api_respond_error_sign_in_with_email_and_password);
}

static void HandleSignInWithEmailLink(
    FirebaseAuthAuthPigeonFirebaseApp* app, const gchar* email,
    const gchar* email_link,
    FirebaseAuthFirebaseAuthHostApiResponseHandle* response_handle,
    gpointer user_data) {
  firebase_auth_firebase_auth_host_api_respond_error_sign_in_with_email_link(
      response_handle, "unimplemented",
      "SignInWithEmailLink is not available on this platform yet.", nullptr);
}

static void HandleSignInWithProvider(
    FirebaseAuthAuthPigeonFirebaseApp* app,
    FirebaseAuthInternalSignInProvider* sign_in_provider,
    FirebaseAuthFirebaseAuthHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Auth* firebase_auth = GetAuthFromPigeon(app);

  // The provider must outlive the asynchronous sign-in operation, so it is
  // heap-allocated and deleted when the future completes (the Windows
  // implementation passes the address of a temporary, which is not valid
  // C++).
  auto* provider = new firebase::auth::FederatedOAuthProvider(
      GetProviderDataFromArguments(sign_in_provider));

  firebase::Future<firebase::auth::AuthResult> sign_in_future =
      firebase_auth->SignInWithProvider(provider);

  g_object_ref(response_handle);
  sign_in_future.OnCompletion(
      [response_handle, provider](
          const firebase::Future<firebase::auth::AuthResult>&
              completed_future) {
        delete provider;
        // We are probably in a different thread right now.
        if (completed_future.error() == 0) {
          FirebaseAuthInternalUserCredential* credential =
              ParseAuthResult(completed_future.result());
          PostToMainThread([response_handle, credential]() {
            firebase_auth_firebase_auth_host_api_respond_sign_in_with_provider(
                response_handle, credential);
            g_object_unref(credential);
            g_object_unref(response_handle);
          });
        } else {
          RespondFutureError(
              completed_future, response_handle,
              firebase_auth_firebase_auth_host_api_respond_error_sign_in_with_provider);
        }
      });
}

static void HandleSignOut(
    FirebaseAuthAuthPigeonFirebaseApp* app,
    FirebaseAuthFirebaseAuthHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Auth* firebase_auth = GetAuthFromPigeon(app);
  firebase_auth->SignOut();
  firebase_auth_firebase_auth_host_api_respond_sign_out(response_handle);
}

static void HandleFetchSignInMethodsForEmail(
    FirebaseAuthAuthPigeonFirebaseApp* app, const gchar* email,
    FirebaseAuthFirebaseAuthHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Auth* firebase_auth = GetAuthFromPigeon(app);

  firebase::Future<Auth::FetchProvidersResult> providers_future =
      firebase_auth->FetchProvidersForEmail(email);

  g_object_ref(response_handle);
  providers_future.OnCompletion(
      [response_handle](
          const firebase::Future<Auth::FetchProvidersResult>&
              completed_future) {
        // We are probably in a different thread right now.
        if (completed_future.error() == 0) {
          FlValue* providers = fl_value_new_list();
          for (const std::string& provider :
               completed_future.result()->providers) {
            fl_value_append_take(providers,
                                 fl_value_new_string(provider.c_str()));
          }
          PostToMainThread([response_handle, providers]() {
            firebase_auth_firebase_auth_host_api_respond_fetch_sign_in_methods_for_email(
                response_handle, providers);
            fl_value_unref(providers);
            g_object_unref(response_handle);
          });
        } else {
          RespondFutureError(
              completed_future, response_handle,
              firebase_auth_firebase_auth_host_api_respond_error_fetch_sign_in_methods_for_email);
        }
      });
}

static void HandleSendPasswordResetEmail(
    FirebaseAuthAuthPigeonFirebaseApp* app, const gchar* email,
    FirebaseAuthInternalActionCodeSettings* action_code_settings,
    FirebaseAuthFirebaseAuthHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Auth* firebase_auth = GetAuthFromPigeon(app);
  CompleteVoidFuture(
      firebase_auth->SendPasswordResetEmail(email), response_handle,
      firebase_auth_firebase_auth_host_api_respond_send_password_reset_email,
      firebase_auth_firebase_auth_host_api_respond_error_send_password_reset_email);
}

static void HandleSendSignInLinkToEmail(
    FirebaseAuthAuthPigeonFirebaseApp* app, const gchar* email,
    FirebaseAuthInternalActionCodeSettings* action_code_settings,
    FirebaseAuthFirebaseAuthHostApiResponseHandle* response_handle,
    gpointer user_data) {
  firebase_auth_firebase_auth_host_api_respond_error_send_sign_in_link_to_email(
      response_handle, "unimplemented",
      "SendSignInLinkToEmail is not available on this platform yet.", nullptr);
}

static void HandleSetLanguageCode(
    FirebaseAuthAuthPigeonFirebaseApp* app, const gchar* language_code,
    FirebaseAuthFirebaseAuthHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Auth* firebase_auth = GetAuthFromPigeon(app);

  if (language_code == nullptr) {
    firebase_auth->UseAppLanguage();
    firebase_auth_firebase_auth_host_api_respond_set_language_code(
        response_handle, firebase_auth->language_code().c_str());
    return;
  }

  firebase_auth->set_language_code(language_code);
  firebase_auth_firebase_auth_host_api_respond_set_language_code(
      response_handle, language_code);
}

static void HandleSetSettings(
    FirebaseAuthAuthPigeonFirebaseApp* app,
    FirebaseAuthInternalFirebaseAuthSettings* settings,
    FirebaseAuthFirebaseAuthHostApiResponseHandle* response_handle,
    gpointer user_data) {
  firebase_auth_firebase_auth_host_api_respond_error_set_settings(
      response_handle, "unimplemented",
      "SetSettings is not available on this platform yet.", nullptr);
}

static void HandleVerifyPasswordResetCode(
    FirebaseAuthAuthPigeonFirebaseApp* app, const gchar* code,
    FirebaseAuthFirebaseAuthHostApiResponseHandle* response_handle,
    gpointer user_data) {
  firebase_auth_firebase_auth_host_api_respond_error_verify_password_reset_code(
      response_handle, "unimplemented",
      "VerifyPasswordResetCode is not available on this platform yet.",
      nullptr);
}

static void HandleVerifyPhoneNumber(
    FirebaseAuthAuthPigeonFirebaseApp* app,
    FirebaseAuthInternalVerifyPhoneNumberRequest* request,
    FirebaseAuthFirebaseAuthHostApiResponseHandle* response_handle,
    gpointer user_data) {
  firebase_auth_firebase_auth_host_api_respond_error_verify_phone_number(
      response_handle, "unimplemented",
      "VerifyPhoneNumber is not available on this platform yet.", nullptr);
}

static void HandleRevokeTokenWithAuthorizationCode(
    FirebaseAuthAuthPigeonFirebaseApp* app, const gchar* authorization_code,
    FirebaseAuthFirebaseAuthHostApiResponseHandle* response_handle,
    gpointer user_data) {
  firebase_auth_firebase_auth_host_api_respond_error_revoke_token_with_authorization_code(
      response_handle, "unimplemented",
      "RevokeTokenWithAuthorizationCode is not available on this platform "
      "yet.",
      nullptr);
}

static void HandleRevokeAccessToken(
    FirebaseAuthAuthPigeonFirebaseApp* app, const gchar* access_token,
    FirebaseAuthFirebaseAuthHostApiResponseHandle* response_handle,
    gpointer user_data) {
  firebase_auth_firebase_auth_host_api_respond_error_revoke_access_token(
      response_handle, "unimplemented",
      "RevokeAccessToken is not available on this platform.", nullptr);
}

static void HandleInitializeRecaptchaConfig(
    FirebaseAuthAuthPigeonFirebaseApp* app,
    FirebaseAuthFirebaseAuthHostApiResponseHandle* response_handle,
    gpointer user_data) {
  firebase_auth_firebase_auth_host_api_respond_error_initialize_recaptcha_config(
      response_handle, "unimplemented",
      "InitializeRecaptchaConfig is not available on this platform yet.",
      nullptr);
}

// FirebaseAuthUserHostApi implementation.

static void HandleDelete(
    FirebaseAuthAuthPigeonFirebaseApp* app,
    FirebaseAuthFirebaseAuthUserHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Auth* firebase_auth = GetAuthFromPigeon(app);
  firebase::auth::User user = firebase_auth->current_user();
  CompleteVoidFuture(
      user.Delete(), response_handle,
      firebase_auth_firebase_auth_user_host_api_respond_delete,
      firebase_auth_firebase_auth_user_host_api_respond_error_delete);
}

static void HandleGetIdToken(
    FirebaseAuthAuthPigeonFirebaseApp* app, gboolean force_refresh,
    FirebaseAuthFirebaseAuthUserHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Auth* firebase_auth = GetAuthFromPigeon(app);
  firebase::auth::User user = firebase_auth->current_user();

  firebase::Future<std::string> token_future = user.GetToken(force_refresh);

  g_object_ref(response_handle);
  token_future.OnCompletion(
      [response_handle](
          const firebase::Future<std::string>& completed_future) {
        // We are probably in a different thread right now.
        if (completed_future.error() == 0) {
          FirebaseAuthInternalIdTokenResult* token_result =
              firebase_auth_internal_id_token_result_new(
                  completed_future.result()->c_str(),
                  /* expiration_timestamp= */ nullptr,
                  /* auth_timestamp= */ nullptr,
                  /* issued_at_timestamp= */ nullptr,
                  /* sign_in_provider= */ nullptr, /* claims= */ nullptr,
                  /* sign_in_second_factor= */ nullptr);
          PostToMainThread([response_handle, token_result]() {
            firebase_auth_firebase_auth_user_host_api_respond_get_id_token(
                response_handle, token_result);
            g_object_unref(token_result);
            g_object_unref(response_handle);
          });
        } else {
          RespondFutureError(
              completed_future, response_handle,
              firebase_auth_firebase_auth_user_host_api_respond_error_get_id_token);
        }
      });
}

static void HandleLinkWithCredential(
    FirebaseAuthAuthPigeonFirebaseApp* app, FlValue* input,
    FirebaseAuthFirebaseAuthUserHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Auth* firebase_auth = GetAuthFromPigeon(app);
  firebase::auth::User user = firebase_auth->current_user();
  CompleteAuthResultFuture(
      user.LinkWithCredential(GetCredentialFromArguments(input)),
      response_handle,
      firebase_auth_firebase_auth_user_host_api_respond_link_with_credential,
      firebase_auth_firebase_auth_user_host_api_respond_error_link_with_credential);
}

static void HandleLinkWithProvider(
    FirebaseAuthAuthPigeonFirebaseApp* app,
    FirebaseAuthInternalSignInProvider* sign_in_provider,
    FirebaseAuthFirebaseAuthUserHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Auth* firebase_auth = GetAuthFromPigeon(app);
  firebase::auth::User user = firebase_auth->current_user();

  // See HandleSignInWithProvider for the provider lifetime note.
  auto* provider = new firebase::auth::FederatedOAuthProvider(
      GetProviderDataFromArguments(sign_in_provider));

  firebase::Future<firebase::auth::AuthResult> link_future =
      user.LinkWithProvider(provider);

  g_object_ref(response_handle);
  link_future.OnCompletion(
      [response_handle, provider](
          const firebase::Future<firebase::auth::AuthResult>&
              completed_future) {
        delete provider;
        // We are probably in a different thread right now.
        if (completed_future.error() == 0) {
          FirebaseAuthInternalUserCredential* credential =
              ParseAuthResult(completed_future.result());
          PostToMainThread([response_handle, credential]() {
            firebase_auth_firebase_auth_user_host_api_respond_link_with_provider(
                response_handle, credential);
            g_object_unref(credential);
            g_object_unref(response_handle);
          });
        } else {
          RespondFutureError(
              completed_future, response_handle,
              firebase_auth_firebase_auth_user_host_api_respond_error_link_with_provider);
        }
      });
}

static void HandleReauthenticateWithCredential(
    FirebaseAuthAuthPigeonFirebaseApp* app, FlValue* input,
    FirebaseAuthFirebaseAuthUserHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Auth* firebase_auth = GetAuthFromPigeon(app);
  firebase::auth::User user = firebase_auth->current_user();

  firebase::Future<void> reauth_future =
      user.Reauthenticate(GetCredentialFromArguments(input));

  g_object_ref(response_handle);
  reauth_future.OnCompletion(
      [response_handle,
       firebase_auth](const firebase::Future<void>& completed_future) {
        // We are probably in a different thread right now.
        if (completed_future.error() == 0) {
          // The C++ SDK Reauthenticate() has no result payload, so the
          // credential is rebuilt from the current user. (The Windows
          // implementation never responds on success, leaving the Dart future
          // hanging; responding here is a deliberate improvement.)
          g_autoptr(FirebaseAuthInternalUserDetails) user_details =
              ParseUserDetails(firebase_auth->current_user());
          FirebaseAuthInternalUserCredential* credential =
              firebase_auth_internal_user_credential_new(
                  user_details, /* additional_user_info= */ nullptr,
                  /* credential= */ nullptr);
          PostToMainThread([response_handle, credential]() {
            firebase_auth_firebase_auth_user_host_api_respond_reauthenticate_with_credential(
                response_handle, credential);
            g_object_unref(credential);
            g_object_unref(response_handle);
          });
        } else {
          RespondFutureError(
              completed_future, response_handle,
              firebase_auth_firebase_auth_user_host_api_respond_error_reauthenticate_with_credential);
        }
      });
}

static void HandleReauthenticateWithProvider(
    FirebaseAuthAuthPigeonFirebaseApp* app,
    FirebaseAuthInternalSignInProvider* sign_in_provider,
    FirebaseAuthFirebaseAuthUserHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Auth* firebase_auth = GetAuthFromPigeon(app);
  firebase::auth::User user = firebase_auth->current_user();

  // See HandleSignInWithProvider for the provider lifetime note.
  auto* provider = new firebase::auth::FederatedOAuthProvider(
      GetProviderDataFromArguments(sign_in_provider));

  firebase::Future<firebase::auth::AuthResult> reauth_future =
      user.ReauthenticateWithProvider(provider);

  g_object_ref(response_handle);
  reauth_future.OnCompletion(
      [response_handle, provider](
          const firebase::Future<firebase::auth::AuthResult>&
              completed_future) {
        delete provider;
        // We are probably in a different thread right now.
        if (completed_future.error() == 0) {
          FirebaseAuthInternalUserCredential* credential =
              ParseAuthResult(completed_future.result());
          PostToMainThread([response_handle, credential]() {
            firebase_auth_firebase_auth_user_host_api_respond_reauthenticate_with_provider(
                response_handle, credential);
            g_object_unref(credential);
            g_object_unref(response_handle);
          });
        } else {
          RespondFutureError(
              completed_future, response_handle,
              firebase_auth_firebase_auth_user_host_api_respond_error_reauthenticate_with_provider);
        }
      });
}

static void HandleReload(
    FirebaseAuthAuthPigeonFirebaseApp* app,
    FirebaseAuthFirebaseAuthUserHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Auth* firebase_auth = GetAuthFromPigeon(app);
  firebase::auth::User user = firebase_auth->current_user();
  CompleteUserDetailsFuture(
      user.Reload(), firebase_auth, response_handle,
      firebase_auth_firebase_auth_user_host_api_respond_reload,
      firebase_auth_firebase_auth_user_host_api_respond_error_reload);
}

static void HandleSendEmailVerification(
    FirebaseAuthAuthPigeonFirebaseApp* app,
    FirebaseAuthInternalActionCodeSettings* action_code_settings,
    FirebaseAuthFirebaseAuthUserHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Auth* firebase_auth = GetAuthFromPigeon(app);
  firebase::auth::User user = firebase_auth->current_user();
  CompleteVoidFuture(
      user.SendEmailVerification(), response_handle,
      firebase_auth_firebase_auth_user_host_api_respond_send_email_verification,
      firebase_auth_firebase_auth_user_host_api_respond_error_send_email_verification);
}

static void HandleUnlink(
    FirebaseAuthAuthPigeonFirebaseApp* app, const gchar* provider_id,
    FirebaseAuthFirebaseAuthUserHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Auth* firebase_auth = GetAuthFromPigeon(app);
  firebase::auth::User user = firebase_auth->current_user();
  CompleteAuthResultFuture(
      user.Unlink(provider_id), response_handle,
      firebase_auth_firebase_auth_user_host_api_respond_unlink,
      firebase_auth_firebase_auth_user_host_api_respond_error_unlink);
}

static void HandleUpdateEmail(
    FirebaseAuthAuthPigeonFirebaseApp* app, const gchar* new_email,
    FirebaseAuthFirebaseAuthUserHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Auth* firebase_auth = GetAuthFromPigeon(app);
  firebase::auth::User user = firebase_auth->current_user();
  CompleteUserDetailsFuture(
      user.SendEmailVerificationBeforeUpdatingEmail(new_email), firebase_auth,
      response_handle,
      firebase_auth_firebase_auth_user_host_api_respond_update_email,
      firebase_auth_firebase_auth_user_host_api_respond_error_update_email);
}

static void HandleUpdatePassword(
    FirebaseAuthAuthPigeonFirebaseApp* app, const gchar* new_password,
    FirebaseAuthFirebaseAuthUserHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Auth* firebase_auth = GetAuthFromPigeon(app);
  firebase::auth::User user = firebase_auth->current_user();
  CompleteUserDetailsFuture(
      user.UpdatePassword(new_password), firebase_auth, response_handle,
      firebase_auth_firebase_auth_user_host_api_respond_update_password,
      firebase_auth_firebase_auth_user_host_api_respond_error_update_password);
}

static void HandleUpdatePhoneNumber(
    FirebaseAuthAuthPigeonFirebaseApp* app, FlValue* input,
    FirebaseAuthFirebaseAuthUserHostApiResponseHandle* response_handle,
    gpointer user_data) {
  // The C++ SDK cannot construct a PhoneAuthCredential from a verificationId
  // and smsCode (see the Windows TODO in getPhoneCredentialFromArguments), so
  // this cannot be implemented on desktop yet. The Windows implementation
  // attempts the call with an empty credential (and throws on unknown
  // methods); responding with an error is a deliberate improvement.
  firebase_auth_firebase_auth_user_host_api_respond_error_update_phone_number(
      response_handle, "unimplemented",
      "UpdatePhoneNumber is not available on this platform yet.", nullptr);
}

static void HandleUpdateProfile(
    FirebaseAuthAuthPigeonFirebaseApp* app,
    FirebaseAuthInternalUserProfile* profile,
    FirebaseAuthFirebaseAuthUserHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Auth* firebase_auth = GetAuthFromPigeon(app);
  firebase::auth::User user = firebase_auth->current_user();

  firebase::auth::User::UserProfile user_profile;

  if (firebase_auth_internal_user_profile_get_display_name_changed(profile)) {
    user_profile.display_name =
        firebase_auth_internal_user_profile_get_display_name(profile);
  }
  if (firebase_auth_internal_user_profile_get_photo_url_changed(profile)) {
    user_profile.photo_url =
        firebase_auth_internal_user_profile_get_photo_url(profile);
  }

  CompleteUserDetailsFuture(
      user.UpdateUserProfile(user_profile), firebase_auth, response_handle,
      firebase_auth_firebase_auth_user_host_api_respond_update_profile,
      firebase_auth_firebase_auth_user_host_api_respond_error_update_profile);
}

static void HandleVerifyBeforeUpdateEmail(
    FirebaseAuthAuthPigeonFirebaseApp* app, const gchar* new_email,
    FirebaseAuthInternalActionCodeSettings* action_code_settings,
    FirebaseAuthFirebaseAuthUserHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Auth* firebase_auth = GetAuthFromPigeon(app);
  firebase::auth::User user = firebase_auth->current_user();

  if (action_code_settings != nullptr) {
    g_warning(
        "Firebase C++ SDK does not support using `ActionCodeSettings` for "
        "`verifyBeforeUpdateEmail()` API currently");
  }

  CompleteVoidFuture(
      user.SendEmailVerificationBeforeUpdatingEmail(new_email),
      response_handle,
      firebase_auth_firebase_auth_user_host_api_respond_verify_before_update_email,
      firebase_auth_firebase_auth_user_host_api_respond_error_verify_before_update_email);
}

// Method handler vtables. The entries are in the order the members are
// declared in the generated vtable structs.

static const FirebaseAuthFirebaseAuthHostApiVTable kFirebaseAuthHostApiVTable =
    {
        HandleRegisterIdTokenListener,     // register_id_token_listener
        HandleRegisterAuthStateListener,   // register_auth_state_listener
        HandleUseEmulator,                 // use_emulator
        HandleApplyActionCode,             // apply_action_code
        HandleCheckActionCode,             // check_action_code
        HandleConfirmPasswordReset,        // confirm_password_reset
        HandleCreateUserWithEmailAndPassword,  // create_user_with_email_and_password
        HandleSignInAnonymously,           // sign_in_anonymously
        HandleSignInWithCredential,        // sign_in_with_credential
        HandleSignInWithCustomToken,       // sign_in_with_custom_token
        HandleSignInWithEmailAndPassword,  // sign_in_with_email_and_password
        HandleSignInWithEmailLink,         // sign_in_with_email_link
        HandleSignInWithProvider,          // sign_in_with_provider
        HandleSignOut,                     // sign_out
        HandleFetchSignInMethodsForEmail,  // fetch_sign_in_methods_for_email
        HandleSendPasswordResetEmail,      // send_password_reset_email
        HandleSendSignInLinkToEmail,       // send_sign_in_link_to_email
        HandleSetLanguageCode,             // set_language_code
        HandleSetSettings,                 // set_settings
        HandleVerifyPasswordResetCode,     // verify_password_reset_code
        HandleVerifyPhoneNumber,           // verify_phone_number
        HandleRevokeTokenWithAuthorizationCode,  // revoke_token_with_authorization_code
        HandleRevokeAccessToken,           // revoke_access_token
        HandleInitializeRecaptchaConfig,   // initialize_recaptcha_config
};

static const FirebaseAuthFirebaseAuthUserHostApiVTable
    kFirebaseAuthUserHostApiVTable = {
        HandleDelete,                      // delete_
        HandleGetIdToken,                  // get_id_token
        HandleLinkWithCredential,          // link_with_credential
        HandleLinkWithProvider,            // link_with_provider
        HandleReauthenticateWithCredential,  // reauthenticate_with_credential
        HandleReauthenticateWithProvider,  // reauthenticate_with_provider
        HandleReload,                      // reload
        HandleSendEmailVerification,       // send_email_verification
        HandleUnlink,                      // unlink
        HandleUpdateEmail,                 // update_email
        HandleUpdatePassword,              // update_password
        HandleUpdatePhoneNumber,           // update_phone_number
        HandleUpdateProfile,               // update_profile
        HandleVerifyBeforeUpdateEmail,     // verify_before_update_email
};

// FlutterFirebasePlugin implementation, mirroring the Windows plugin's
// GetPluginConstantsForFirebaseApp / DidReinitializeFirebaseCore.
class FirebaseAuthConstantsProvider : public FlutterFirebasePlugin {
 public:
  FlValue* GetPluginConstantsForFirebaseApp(const firebase::App& app) override {
    FlValue* constants = fl_value_new_map();

    Auth* auth = Auth::GetAuth(const_cast<firebase::App*>(&app));
    firebase::auth::User user = auth->current_user();

    if (user.is_valid()) {
      // [userInfoFieldList, providerData], the same shape the auth-state and
      // id-token event channels send.
      g_autoptr(FlValue) event = BuildUserEventPayload(auth);
      FlValue* user_details = fl_value_lookup_string(event, "user");
      fl_value_set_take(constants, fl_value_new_string("APP_CURRENT_USER"),
                        fl_value_ref(user_details));
    }

    std::string language_code = auth->language_code();
    if (!language_code.empty()) {
      fl_value_set_take(constants, fl_value_new_string("APP_LANGUAGE_CODE"),
                        fl_value_new_string(language_code.c_str()));
    }

    return constants;
  }

  void DidReinitializeFirebaseCore() override {
    // No-op for now. Could be used to reset cached auth instances.
  }
};

static void firebase_auth_plugin_dispose(GObject* object) {
  G_OBJECT_CLASS(firebase_auth_plugin_parent_class)->dispose(object);
}

static void firebase_auth_plugin_class_init(FirebaseAuthPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = firebase_auth_plugin_dispose;
}

static void firebase_auth_plugin_init(FirebaseAuthPlugin* self) {}

void firebase_auth_plugin_register_with_registrar(
    FlPluginRegistrar* registrar) {
  FirebaseAuthPlugin* plugin = FIREBASE_AUTH_PLUGIN(
      g_object_new(firebase_auth_plugin_get_type(), nullptr));

  firebase::SetLogLevel(firebase::kLogLevelVerbose);

  FlBinaryMessenger* messenger = fl_plugin_registrar_get_messenger(registrar);
  g_binary_messenger = messenger;

  firebase_auth_firebase_auth_host_api_set_method_handlers(
      messenger, /* suffix= */ nullptr, &kFirebaseAuthHostApiVTable,
      g_object_ref(plugin), g_object_unref);
  firebase_auth_firebase_auth_user_host_api_set_method_handlers(
      messenger, /* suffix= */ nullptr, &kFirebaseAuthUserHostApiVTable,
      g_object_ref(plugin), g_object_unref);
  // Note: like on Windows, the MultiFactor*, Totp* and GenerateInterfaces
  // pigeon APIs are not implemented on this platform, so no handlers are
  // registered for them.

  RegisterFlutterFirebasePlugin("plugins.flutter.io/firebase_auth",
                                new FirebaseAuthConstantsProvider());

  g_object_unref(plugin);

  // Register for platform logging
  App::RegisterLibrary(kLibraryName,
                       firebase_auth_linux::getPluginVersion().c_str(),
                       nullptr);
}
