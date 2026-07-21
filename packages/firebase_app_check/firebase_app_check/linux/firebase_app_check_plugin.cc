// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "include/firebase_app_check/firebase_app_check_plugin.h"

#include <flutter_linux/flutter_linux.h>

#include <map>
#include <string>

#include "firebase/app.h"
#include "firebase/app_check.h"
#include "firebase/app_check/debug_provider.h"
#include "firebase/future.h"
#include "firebase_app_check/plugin_version.h"
#include "messages.g.h"

using ::firebase::App;
using ::firebase::Future;
using ::firebase::app_check::AppCheck;
using ::firebase::app_check::AppCheckListener;
using ::firebase::app_check::AppCheckToken;
using ::firebase::app_check::DebugAppCheckProviderFactory;

static const char kLibraryName[] = "flutter-fire-app-check";
static const char kEventChannelNamePrefix[] =
    "plugins.flutter.io/firebase_app_check/token/";

#define FIREBASE_APP_CHECK_PLUGIN(obj)                                     \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), firebase_app_check_plugin_get_type(), \
                              FirebaseAppCheckPlugin))

struct _FirebaseAppCheckPlugin {
  GObject parent_instance;
};

G_DEFINE_TYPE(FirebaseAppCheckPlugin, firebase_app_check_plugin,
              g_object_get_type())

class FlutterAppCheckListener;

// The messenger is owned by the engine and outlives the plugin.
static FlBinaryMessenger* binary_messenger = nullptr;
// Event channels created by registerTokenListener, keyed by app name.
// The map owns a reference on each channel.
static std::map<std::string, FlEventChannel*> event_channels_;
// Active AppCheck listeners, keyed by app name. The map owns the listeners.
static std::map<std::string, FlutterAppCheckListener*> listeners_map_;

static AppCheck* GetAppCheckFromPigeon(const std::string& app_name) {
  App* app = App::GetInstance(app_name.c_str());
  return AppCheck::GetInstance(app);
}

static void ParseError(const firebase::FutureBase& completed_future,
                       std::string* error_code, std::string* error_message) {
  int error = completed_future.error();
  switch (error) {
    case firebase::app_check::kAppCheckErrorServerUnreachable:
      *error_code = "server-unreachable";
      break;
    case firebase::app_check::kAppCheckErrorInvalidConfiguration:
      *error_code = "invalid-configuration";
      break;
    case firebase::app_check::kAppCheckErrorSystemKeychain:
      *error_code = "system-keychain";
      break;
    case firebase::app_check::kAppCheckErrorUnsupportedProvider:
      *error_code = "unsupported-provider";
      break;
    default:
      *error_code = "unknown";
      break;
  }

  *error_message = completed_future.error_message()
                       ? completed_future.error_message()
                       : "An unknown error occurred";
}

// Token change events are delivered on a Firebase SDK thread; they are
// marshalled to the platform (main) thread with g_idle_add before being sent
// on the event channel.
struct TokenEvent {
  FlEventChannel* channel;  // Owned reference.
  std::string token;
};

static gboolean SendTokenEvent(gpointer user_data) {
  TokenEvent* event = static_cast<TokenEvent*>(user_data);
  g_autoptr(FlValue) map = fl_value_new_map();
  fl_value_set_string_take(map, "token",
                           fl_value_new_string(event->token.c_str()));
  g_autoptr(GError) error = nullptr;
  if (!fl_event_channel_send(event->channel, map, nullptr, &error)) {
    g_warning("firebase_app_check: failed to send token event: %s",
              error->message);
  }
  g_object_unref(event->channel);
  delete event;
  return G_SOURCE_REMOVE;
}

// AppCheckListener implementation that forwards token changes to an
// FlEventChannel.
class FlutterAppCheckListener : public AppCheckListener {
 public:
  explicit FlutterAppCheckListener(FlEventChannel* channel)
      : channel_(FL_EVENT_CHANNEL(g_object_ref(channel))) {}

  ~FlutterAppCheckListener() override { g_object_unref(channel_); }

  void OnAppCheckTokenChanged(const AppCheckToken& token) override {
    TokenEvent* event =
        new TokenEvent{FL_EVENT_CHANNEL(g_object_ref(channel_)), token.token};
    g_idle_add(SendTokenEvent, event);
  }

 private:
  FlEventChannel* channel_;
};

// Stream handlers for token change events.

struct TokenStreamHandlerData {
  std::string app_name;
};

static FlMethodErrorResponse* OnListenTokenChannel(FlEventChannel* channel,
                                                   FlValue* args,
                                                   gpointer user_data) {
  TokenStreamHandlerData* data =
      static_cast<TokenStreamHandlerData*>(user_data);
  AppCheck* app_check = GetAppCheckFromPigeon(data->app_name);
  FlutterAppCheckListener* listener = new FlutterAppCheckListener(channel);
  app_check->AddAppCheckListener(listener);
  listeners_map_[data->app_name] = listener;
  return nullptr;
}

static FlMethodErrorResponse* OnCancelTokenChannel(FlEventChannel* channel,
                                                   FlValue* args,
                                                   gpointer user_data) {
  TokenStreamHandlerData* data =
      static_cast<TokenStreamHandlerData*>(user_data);
  auto it = listeners_map_.find(data->app_name);
  if (it != listeners_map_.end()) {
    AppCheck* app_check = GetAppCheckFromPigeon(data->app_name);
    app_check->RemoveAppCheckListener(it->second);
    delete it->second;
    listeners_map_.erase(it);
  }
  return nullptr;
}

static void DestroyTokenStreamHandlerData(gpointer user_data) {
  delete static_cast<TokenStreamHandlerData*>(user_data);
}

// Firebase Future completions run on an SDK thread; responses are marshalled
// back to the platform (main) thread with g_idle_add before replying over the
// pigeon channel.
enum class TokenRequestKind { kGetToken, kGetLimitedUseToken };

struct TokenRequestResult {
  TokenRequestKind kind;
  // Owned reference, released after responding.
  FirebaseAppCheckFirebaseAppCheckHostApiResponseHandle* response_handle;
  bool success;
  bool has_token;
  std::string token;
  std::string error_code;
  std::string error_message;
};

static gboolean RespondTokenRequest(gpointer user_data) {
  TokenRequestResult* result = static_cast<TokenRequestResult*>(user_data);
  switch (result->kind) {
    case TokenRequestKind::kGetToken:
      if (result->success) {
        firebase_app_check_firebase_app_check_host_api_respond_get_token(
            result->response_handle,
            result->has_token ? result->token.c_str() : nullptr);
      } else {
        firebase_app_check_firebase_app_check_host_api_respond_error_get_token(
            result->response_handle, result->error_code.c_str(),
            result->error_message.c_str(), nullptr);
      }
      break;
    case TokenRequestKind::kGetLimitedUseToken:
      if (result->success) {
        firebase_app_check_firebase_app_check_host_api_respond_get_limited_use_app_check_token(
            result->response_handle, result->token.c_str());
      } else {
        firebase_app_check_firebase_app_check_host_api_respond_error_get_limited_use_app_check_token(
            result->response_handle, result->error_code.c_str(),
            result->error_message.c_str(), nullptr);
      }
      break;
  }
  return G_SOURCE_REMOVE;
}

static void DestroyTokenRequestResult(gpointer user_data) {
  TokenRequestResult* result = static_cast<TokenRequestResult*>(user_data);
  g_object_unref(result->response_handle);
  delete result;
}

// FirebaseAppCheckHostApi

static void HandleActivate(
    const gchar* app_name, const gchar* android_provider,
    const gchar* apple_provider, const gchar* debug_token,
    FirebaseAppCheckFirebaseAppCheckHostApiResponseHandle* response_handle,
    gpointer user_data) {
  // On Linux/desktop, only the Debug provider is available.
  DebugAppCheckProviderFactory* factory =
      DebugAppCheckProviderFactory::GetInstance();

  if (debug_token != nullptr && debug_token[0] != '\0') {
    factory->SetDebugToken(debug_token);
  }

  AppCheck::SetAppCheckProviderFactory(factory);

  firebase_app_check_firebase_app_check_host_api_respond_activate(
      response_handle);
}

static void HandleGetToken(
    const gchar* app_name, gboolean force_refresh,
    FirebaseAppCheckFirebaseAppCheckHostApiResponseHandle* response_handle,
    gpointer user_data) {
  AppCheck* app_check = GetAppCheckFromPigeon(app_name);

  // The response handle must outlive this callback; released in
  // RespondTokenRequest.
  g_object_ref(response_handle);

  Future<AppCheckToken> future = app_check->GetAppCheckToken(force_refresh);
  future.OnCompletion([response_handle](
                          const Future<AppCheckToken>& completed_future) {
    TokenRequestResult* result = new TokenRequestResult();
    result->kind = TokenRequestKind::kGetToken;
    result->response_handle = response_handle;
    if (completed_future.error() != 0) {
      result->success = false;
      ParseError(completed_future, &result->error_code, &result->error_message);
    } else {
      result->success = true;
      const AppCheckToken* token = completed_future.result();
      if (token) {
        result->has_token = true;
        result->token = token->token;
      } else {
        result->has_token = false;
      }
    }
    g_idle_add_full(G_PRIORITY_DEFAULT, RespondTokenRequest, result,
                    DestroyTokenRequestResult);
  });
}

static void HandleSetTokenAutoRefreshEnabled(
    const gchar* app_name, gboolean is_token_auto_refresh_enabled,
    FirebaseAppCheckFirebaseAppCheckHostApiResponseHandle* response_handle,
    gpointer user_data) {
  AppCheck* app_check = GetAppCheckFromPigeon(app_name);
  app_check->SetTokenAutoRefreshEnabled(is_token_auto_refresh_enabled);
  firebase_app_check_firebase_app_check_host_api_respond_set_token_auto_refresh_enabled(
      response_handle);
}

static void HandleRegisterTokenListener(
    const gchar* app_name,
    FirebaseAppCheckFirebaseAppCheckHostApiResponseHandle* response_handle,
    gpointer user_data) {
  const std::string name = std::string(kEventChannelNamePrefix) + app_name;

  // Reuse an existing channel on re-registration (e.g. hot restart); creating
  // a second FlEventChannel with the same name would detach the first one's
  // stream handlers.
  if (event_channels_.find(app_name) == event_channels_.end()) {
    g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
    FlEventChannel* event_channel = fl_event_channel_new(
        binary_messenger, name.c_str(), FL_METHOD_CODEC(codec));
    fl_event_channel_set_stream_handlers(
        event_channel, OnListenTokenChannel, OnCancelTokenChannel,
        new TokenStreamHandlerData{app_name}, DestroyTokenStreamHandlerData);
    event_channels_[app_name] = event_channel;
  }

  firebase_app_check_firebase_app_check_host_api_respond_register_token_listener(
      response_handle, name.c_str());
}

static void HandleGetLimitedUseAppCheckToken(
    const gchar* app_name,
    FirebaseAppCheckFirebaseAppCheckHostApiResponseHandle* response_handle,
    gpointer user_data) {
  AppCheck* app_check = GetAppCheckFromPigeon(app_name);

  // The response handle must outlive this callback; released in
  // RespondTokenRequest.
  g_object_ref(response_handle);

  Future<AppCheckToken> future = app_check->GetLimitedUseAppCheckToken();
  future.OnCompletion([response_handle](
                          const Future<AppCheckToken>& completed_future) {
    TokenRequestResult* result = new TokenRequestResult();
    result->kind = TokenRequestKind::kGetLimitedUseToken;
    result->response_handle = response_handle;
    if (completed_future.error() != 0) {
      result->success = false;
      ParseError(completed_future, &result->error_code, &result->error_message);
    } else {
      const AppCheckToken* token = completed_future.result();
      if (token) {
        result->success = true;
        result->token = token->token;
      } else {
        result->success = false;
        result->error_code = "unknown";
        result->error_message = "Failed to get limited use token";
      }
    }
    g_idle_add_full(G_PRIORITY_DEFAULT, RespondTokenRequest, result,
                    DestroyTokenRequestResult);
  });
}

static const FirebaseAppCheckFirebaseAppCheckHostApiVTable
    kFirebaseAppCheckHostApiVTable = {
        HandleActivate,                    // activate
        HandleGetToken,                    // get_token
        HandleSetTokenAutoRefreshEnabled,  // set_token_auto_refresh_enabled
        HandleRegisterTokenListener,       // register_token_listener
        HandleGetLimitedUseAppCheckToken,  // get_limited_use_app_check_token
};

static void firebase_app_check_plugin_dispose(GObject* object) {
  for (auto& [app_name, listener] : listeners_map_) {
    App* app = App::GetInstance(app_name.c_str());
    if (app) {
      AppCheck* app_check = AppCheck::GetInstance(app);
      if (app_check) {
        app_check->RemoveAppCheckListener(listener);
      }
    }
    delete listener;
  }
  listeners_map_.clear();
  for (auto& [app_name, channel] : event_channels_) {
    g_object_unref(channel);
  }
  event_channels_.clear();
  G_OBJECT_CLASS(firebase_app_check_plugin_parent_class)->dispose(object);
}

static void firebase_app_check_plugin_class_init(
    FirebaseAppCheckPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = firebase_app_check_plugin_dispose;
}

static void firebase_app_check_plugin_init(FirebaseAppCheckPlugin* self) {}

void firebase_app_check_plugin_register_with_registrar(
    FlPluginRegistrar* registrar) {
  FirebaseAppCheckPlugin* plugin = FIREBASE_APP_CHECK_PLUGIN(
      g_object_new(firebase_app_check_plugin_get_type(), nullptr));

  FlBinaryMessenger* messenger = fl_plugin_registrar_get_messenger(registrar);
  binary_messenger = messenger;

  firebase_app_check_firebase_app_check_host_api_set_method_handlers(
      messenger, /* suffix= */ nullptr, &kFirebaseAppCheckHostApiVTable,
      g_object_ref(plugin), g_object_unref);

  g_object_unref(plugin);

  // Register for platform logging
  App::RegisterLibrary(kLibraryName,
                       firebase_app_check_linux::getPluginVersion().c_str(),
                       nullptr);
}
