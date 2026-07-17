// Copyright 2025, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "include/firebase_remote_config/firebase_remote_config_plugin.h"

#include <flutter_linux/flutter_linux.h>

#include <cstdint>
#include <functional>
#include <map>
#include <memory>
#include <string>
#include <utility>
#include <vector>

#include "firebase/app.h"
#include "firebase/future.h"
#include "firebase/remote_config.h"
#include "firebase/remote_config/config_update_listener_registration.h"
#include "firebase/variant.h"
#include "firebase_remote_config/plugin_version.h"
#include "messages.g.h"

using ::firebase::App;
using ::firebase::Future;
using ::firebase::Variant;
using ::firebase::remote_config::ConfigInfo;
using ::firebase::remote_config::ConfigSettings;
using ::firebase::remote_config::RemoteConfig;

static const char kLibraryName[] = "flutter-fire-rc";
static const char kEventChannelName[] =
    "plugins.flutter.io/firebase_remote_config_updated";

#define FIREBASE_REMOTE_CONFIG_PLUGIN(obj)                                     \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), firebase_remote_config_plugin_get_type(), \
                              FirebaseRemoteConfigPlugin))

struct _FirebaseRemoteConfigPlugin {
  GObject parent_instance;

  // Event channel for realtime config update events.
  FlEventChannel* event_channel;

  // Config update listener registrations keyed by Firebase app name.
  std::map<std::string,
           firebase::remote_config::ConfigUpdateListenerRegistration>*
      listeners_map;
};

G_DEFINE_TYPE(FirebaseRemoteConfigPlugin, firebase_remote_config_plugin,
              g_object_get_type())

// Runs |function| on the GLib main thread. Firebase future completions and
// config update callbacks arrive on background threads, but FlBinaryMessenger
// and FlEventChannel calls must be made from the main thread.
static void RunOnMainThread(std::function<void()> function) {
  auto* callback = new std::function<void()>(std::move(function));
  g_idle_add(
      [](gpointer user_data) -> gboolean {
        auto* function = static_cast<std::function<void()>*>(user_data);
        (*function)();
        delete function;
        return G_SOURCE_REMOVE;
      },
      callback);
}

static RemoteConfig* GetRemoteConfigFromPigeon(const std::string& app_name) {
  App* app = App::GetInstance(app_name.c_str());
  RemoteConfig* remote_config = RemoteConfig::GetInstance(app);
  return remote_config;
}

static std::string MapValueSource(firebase::remote_config::ValueSource source) {
  switch (source) {
    case firebase::remote_config::kValueSourceRemoteValue:
      return "remote";
    case firebase::remote_config::kValueSourceDefaultValue:
      return "default";
    case firebase::remote_config::kValueSourceStaticValue:
    default:
      return "static";
  }
}

static std::string MapLastFetchStatus(
    firebase::remote_config::LastFetchStatus status) {
  switch (status) {
    case firebase::remote_config::kLastFetchStatusSuccess:
      return "success";
    case firebase::remote_config::kLastFetchStatusFailure:
      return "failure";
    case firebase::remote_config::kLastFetchStatusPending:
      return "noFetchYet";
    default:
      return "noFetchYet";
  }
}

static std::string GetRemoteConfigErrorCode(int error) {
  switch (error) {
    case firebase::remote_config::kFetchFailureReasonThrottled:
      return "throttle";
    case firebase::remote_config::kFetchFailureReasonInvalid:
      return "invalid";
    default:
      return "unknown";
  }
}

static std::string GetFutureErrorMessage(
    const firebase::FutureBase& completed_future) {
  return completed_future.error_message() ? completed_future.error_message()
                                          : "An unknown error occurred";
}

// FirebaseRemoteConfigHostApi

static void HandleFetch(
    const gchar* app_name,
    FirebaseRemoteConfigFirebaseRemoteConfigHostApiResponseHandle*
        response_handle,
    gpointer user_data) {
  RemoteConfig* remote_config = GetRemoteConfigFromPigeon(app_name);

  g_object_ref(response_handle);
  Future<void> future = remote_config->Fetch();
  future.OnCompletion([response_handle](const Future<void>& completed_future) {
    int error = completed_future.error();
    std::string error_code = GetRemoteConfigErrorCode(error);
    std::string error_message = GetFutureErrorMessage(completed_future);
    RunOnMainThread([response_handle, error, error_code, error_message]() {
      if (error != 0) {
        firebase_remote_config_firebase_remote_config_host_api_respond_error_fetch(
            response_handle, error_code.c_str(), error_message.c_str(),
            nullptr);
      } else {
        firebase_remote_config_firebase_remote_config_host_api_respond_fetch(
            response_handle);
      }
      g_object_unref(response_handle);
    });
  });
}

static void HandleFetchAndActivate(
    const gchar* app_name,
    FirebaseRemoteConfigFirebaseRemoteConfigHostApiResponseHandle*
        response_handle,
    gpointer user_data) {
  RemoteConfig* remote_config = GetRemoteConfigFromPigeon(app_name);

  g_object_ref(response_handle);
  Future<bool> future = remote_config->FetchAndActivate();
  future.OnCompletion([response_handle](const Future<bool>& completed_future) {
    int error = completed_future.error();
    std::string error_code = GetRemoteConfigErrorCode(error);
    std::string error_message = GetFutureErrorMessage(completed_future);
    bool activated = error == 0 ? *completed_future.result() : false;
    RunOnMainThread([response_handle, error, error_code, error_message,
                     activated]() {
      if (error != 0) {
        firebase_remote_config_firebase_remote_config_host_api_respond_error_fetch_and_activate(
            response_handle, error_code.c_str(), error_message.c_str(),
            nullptr);
      } else {
        firebase_remote_config_firebase_remote_config_host_api_respond_fetch_and_activate(
            response_handle, activated);
      }
      g_object_unref(response_handle);
    });
  });
}

static void HandleActivate(
    const gchar* app_name,
    FirebaseRemoteConfigFirebaseRemoteConfigHostApiResponseHandle*
        response_handle,
    gpointer user_data) {
  RemoteConfig* remote_config = GetRemoteConfigFromPigeon(app_name);

  g_object_ref(response_handle);
  Future<bool> future = remote_config->Activate();
  future.OnCompletion([response_handle](const Future<bool>& completed_future) {
    int error = completed_future.error();
    std::string error_code = GetRemoteConfigErrorCode(error);
    std::string error_message = GetFutureErrorMessage(completed_future);
    bool activated = error == 0 ? *completed_future.result() : false;
    RunOnMainThread([response_handle, error, error_code, error_message,
                     activated]() {
      if (error != 0) {
        firebase_remote_config_firebase_remote_config_host_api_respond_error_activate(
            response_handle, error_code.c_str(), error_message.c_str(),
            nullptr);
      } else {
        firebase_remote_config_firebase_remote_config_host_api_respond_activate(
            response_handle, activated);
      }
      g_object_unref(response_handle);
    });
  });
}

static void HandleSetConfigSettings(
    const gchar* app_name,
    FirebaseRemoteConfigRemoteConfigPigeonSettings* settings,
    FirebaseRemoteConfigFirebaseRemoteConfigHostApiResponseHandle*
        response_handle,
    gpointer user_data) {
  RemoteConfig* remote_config = GetRemoteConfigFromPigeon(app_name);

  ConfigSettings config_settings;
  config_settings.minimum_fetch_interval_in_milliseconds =
      firebase_remote_config_remote_config_pigeon_settings_get_minimum_fetch_interval_seconds(
          settings) *
      1000;
  config_settings.fetch_timeout_in_milliseconds =
      firebase_remote_config_remote_config_pigeon_settings_get_fetch_timeout_seconds(
          settings) *
      1000;

  g_object_ref(response_handle);
  Future<void> future = remote_config->SetConfigSettings(config_settings);
  future.OnCompletion([response_handle](const Future<void>& completed_future) {
    int error = completed_future.error();
    std::string error_code = GetRemoteConfigErrorCode(error);
    std::string error_message = GetFutureErrorMessage(completed_future);
    RunOnMainThread([response_handle, error, error_code, error_message]() {
      if (error != 0) {
        firebase_remote_config_firebase_remote_config_host_api_respond_error_set_config_settings(
            response_handle, error_code.c_str(), error_message.c_str(),
            nullptr);
      } else {
        firebase_remote_config_firebase_remote_config_host_api_respond_set_config_settings(
            response_handle);
      }
      g_object_unref(response_handle);
    });
  });
}

static void HandleSetDefaults(
    const gchar* app_name, FlValue* default_parameters,
    FirebaseRemoteConfigFirebaseRemoteConfigHostApiResponseHandle*
        response_handle,
    gpointer user_data) {
  RemoteConfig* remote_config = GetRemoteConfigFromPigeon(app_name);

  // Convert the FlValue map to a vector of ConfigKeyValueVariant. The keys
  // vector owns the key strings; it is reserved up front so the c_str()
  // pointers stored in |defaults| stay valid.
  size_t size = fl_value_get_length(default_parameters);
  std::vector<std::string> keys;
  keys.reserve(size);
  std::vector<firebase::remote_config::ConfigKeyValueVariant> defaults;
  defaults.reserve(size);

  for (size_t i = 0; i < size; i++) {
    FlValue* key_value = fl_value_get_map_key(default_parameters, i);
    FlValue* value_value = fl_value_get_map_value(default_parameters, i);
    keys.emplace_back(fl_value_get_string(key_value));

    Variant value;
    switch (fl_value_get_type(value_value)) {
      case FL_VALUE_TYPE_STRING:
        value = Variant(std::string(fl_value_get_string(value_value)));
        break;
      case FL_VALUE_TYPE_INT:
        value = Variant(static_cast<int64_t>(fl_value_get_int(value_value)));
        break;
      case FL_VALUE_TYPE_FLOAT:
        value = Variant(fl_value_get_float(value_value));
        break;
      case FL_VALUE_TYPE_BOOL:
        value = Variant(static_cast<bool>(fl_value_get_bool(value_value)));
        break;
      default:
        // For null or unsupported types, use empty string
        value = Variant("");
        break;
    }

    defaults.push_back({keys.back().c_str(), value});
  }

  g_object_ref(response_handle);
  Future<void> future =
      remote_config->SetDefaults(defaults.data(), defaults.size());
  future.OnCompletion([response_handle](const Future<void>& completed_future) {
    int error = completed_future.error();
    std::string error_code = GetRemoteConfigErrorCode(error);
    std::string error_message = GetFutureErrorMessage(completed_future);
    RunOnMainThread([response_handle, error, error_code, error_message]() {
      if (error != 0) {
        firebase_remote_config_firebase_remote_config_host_api_respond_error_set_defaults(
            response_handle, error_code.c_str(), error_message.c_str(),
            nullptr);
      } else {
        firebase_remote_config_firebase_remote_config_host_api_respond_set_defaults(
            response_handle);
      }
      g_object_unref(response_handle);
    });
  });
}

static void HandleEnsureInitialized(
    const gchar* app_name,
    FirebaseRemoteConfigFirebaseRemoteConfigHostApiResponseHandle*
        response_handle,
    gpointer user_data) {
  RemoteConfig* remote_config = GetRemoteConfigFromPigeon(app_name);

  g_object_ref(response_handle);
  Future<ConfigInfo> future = remote_config->EnsureInitialized();
  future.OnCompletion([response_handle](
                          const Future<ConfigInfo>& completed_future) {
    int error = completed_future.error();
    std::string error_code = GetRemoteConfigErrorCode(error);
    std::string error_message = GetFutureErrorMessage(completed_future);
    RunOnMainThread([response_handle, error, error_code, error_message]() {
      if (error != 0) {
        firebase_remote_config_firebase_remote_config_host_api_respond_error_ensure_initialized(
            response_handle, error_code.c_str(), error_message.c_str(),
            nullptr);
      } else {
        firebase_remote_config_firebase_remote_config_host_api_respond_ensure_initialized(
            response_handle);
      }
      g_object_unref(response_handle);
    });
  });
}

static void HandleSetCustomSignals(
    const gchar* app_name, FlValue* custom_signals,
    FirebaseRemoteConfigFirebaseRemoteConfigHostApiResponseHandle*
        response_handle,
    gpointer user_data) {
  // SetCustomSignals is not supported on the C++ SDK for desktop platforms.
  firebase_remote_config_firebase_remote_config_host_api_respond_error_set_custom_signals(
      response_handle, "unimplemented",
      "SetCustomSignals is not supported on Linux.", nullptr);
}

static void HandleGetAll(
    const gchar* app_name,
    FirebaseRemoteConfigFirebaseRemoteConfigHostApiResponseHandle*
        response_handle,
    gpointer user_data) {
  RemoteConfig* remote_config = GetRemoteConfigFromPigeon(app_name);

  std::map<std::string, Variant> all_configs = remote_config->GetAll();
  g_autoptr(FlValue) parameters = fl_value_new_map();

  for (const auto& [key, variant] : all_configs) {
    firebase::remote_config::ValueInfo info;
    std::string value_str = remote_config->GetString(key.c_str(), &info);

    g_autoptr(FlValue) value_map = fl_value_new_map();
    fl_value_set_string_take(
        value_map, "value",
        fl_value_new_uint8_list(
            reinterpret_cast<const uint8_t*>(value_str.data()),
            value_str.size()));
    fl_value_set_string_take(
        value_map, "source",
        fl_value_new_string(MapValueSource(info.source).c_str()));

    fl_value_set_string(parameters, key.c_str(), value_map);
  }

  firebase_remote_config_firebase_remote_config_host_api_respond_get_all(
      response_handle, parameters);
}

static void HandleGetProperties(
    const gchar* app_name,
    FirebaseRemoteConfigFirebaseRemoteConfigHostApiResponseHandle*
        response_handle,
    gpointer user_data) {
  RemoteConfig* remote_config = GetRemoteConfigFromPigeon(app_name);

  const ConfigInfo& info = remote_config->GetInfo();
  const ConfigSettings config_settings = remote_config->GetConfigSettings();

  int64_t fetch_timeout_seconds = static_cast<int64_t>(
      config_settings.fetch_timeout_in_milliseconds / 1000);
  int64_t minimum_fetch_interval_seconds = static_cast<int64_t>(
      config_settings.minimum_fetch_interval_in_milliseconds / 1000);
  int64_t last_fetch_time_millis = static_cast<int64_t>(info.fetch_time);

  g_autoptr(FlValue) properties = fl_value_new_map();
  fl_value_set_string_take(properties, "fetchTimeout",
                           fl_value_new_int(fetch_timeout_seconds));
  fl_value_set_string_take(properties, "minimumFetchInterval",
                           fl_value_new_int(minimum_fetch_interval_seconds));
  fl_value_set_string_take(properties, "lastFetchTime",
                           fl_value_new_int(last_fetch_time_millis));
  fl_value_set_string_take(
      properties, "lastFetchStatus",
      fl_value_new_string(MapLastFetchStatus(info.last_fetch_status).c_str()));

  firebase_remote_config_firebase_remote_config_host_api_respond_get_properties(
      response_handle, properties);
}

static const FirebaseRemoteConfigFirebaseRemoteConfigHostApiVTable
    kFirebaseRemoteConfigHostApiVTable = {
        HandleFetch,              // fetch
        HandleFetchAndActivate,   // fetch_and_activate
        HandleActivate,           // activate
        HandleSetConfigSettings,  // set_config_settings
        HandleSetDefaults,        // set_defaults
        HandleEnsureInitialized,  // ensure_initialized
        HandleSetCustomSignals,   // set_custom_signals
        HandleGetAll,             // get_all
        HandleGetProperties,      // get_properties
};

// Event channel for config update events.
// Note: The Firebase C++ SDK does not yet support real-time config updates on
// desktop platforms. The listener is registered but the callback will not fire.
// This implementation is ready for when the SDK adds desktop support.

static std::string AppNameFromEventArguments(FlValue* args) {
  std::string app_name = "[DEFAULT]";
  if (args != nullptr && fl_value_get_type(args) == FL_VALUE_TYPE_MAP) {
    FlValue* name_value = fl_value_lookup_string(args, "appName");
    if (name_value != nullptr &&
        fl_value_get_type(name_value) == FL_VALUE_TYPE_STRING) {
      app_name = fl_value_get_string(name_value);
    }
  }
  return app_name;
}

static FlMethodErrorResponse* ConfigUpdateOnListen(FlEventChannel* channel,
                                                   FlValue* args,
                                                   gpointer user_data) {
  FirebaseRemoteConfigPlugin* self = FIREBASE_REMOTE_CONFIG_PLUGIN(user_data);
  std::string app_name = AppNameFromEventArguments(args);

  App* app = App::GetInstance(app_name.c_str());
  RemoteConfig* remote_config = RemoteConfig::GetInstance(app);

  FlEventChannel* event_channel = self->event_channel;
  auto registration = remote_config->AddOnConfigUpdateListener(
      [event_channel](firebase::remote_config::ConfigUpdate&& config_update,
                      firebase::remote_config::RemoteConfigError error) {
        // This callback may fire on a background thread; take a reference to
        // the channel and send the event from the main thread.
        FlEventChannel* channel = FL_EVENT_CHANNEL(g_object_ref(event_channel));
        if (error != firebase::remote_config::kRemoteConfigErrorNone) {
          RunOnMainThread([channel]() {
            fl_event_channel_send_error(channel, "firebase_remote_config",
                                        "Error listening for config updates.",
                                        nullptr, nullptr, nullptr);
            g_object_unref(channel);
          });
          return;
        }
        std::vector<std::string> updated_keys =
            std::move(config_update.updated_keys);
        RunOnMainThread([channel, updated_keys]() {
          g_autoptr(FlValue) keys = fl_value_new_list();
          for (const std::string& key : updated_keys) {
            fl_value_append_take(keys, fl_value_new_string(key.c_str()));
          }
          fl_event_channel_send(channel, keys, nullptr, nullptr);
          g_object_unref(channel);
        });
      });

  (*self->listeners_map)[app_name] = std::move(registration);

  return nullptr;
}

static FlMethodErrorResponse* ConfigUpdateOnCancel(FlEventChannel* channel,
                                                   FlValue* args,
                                                   gpointer user_data) {
  FirebaseRemoteConfigPlugin* self = FIREBASE_REMOTE_CONFIG_PLUGIN(user_data);
  std::string app_name = AppNameFromEventArguments(args);

  auto it = self->listeners_map->find(app_name);
  if (it != self->listeners_map->end()) {
    it->second.Remove();
    self->listeners_map->erase(it);
  }

  return nullptr;
}

static void firebase_remote_config_plugin_dispose(GObject* object) {
  FirebaseRemoteConfigPlugin* self = FIREBASE_REMOTE_CONFIG_PLUGIN(object);
  if (self->listeners_map != nullptr) {
    for (auto& [app_name, registration] : *self->listeners_map) {
      registration.Remove();
    }
    delete self->listeners_map;
    self->listeners_map = nullptr;
  }
  g_clear_object(&self->event_channel);
  G_OBJECT_CLASS(firebase_remote_config_plugin_parent_class)->dispose(object);
}

static void firebase_remote_config_plugin_class_init(
    FirebaseRemoteConfigPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = firebase_remote_config_plugin_dispose;
}

static void firebase_remote_config_plugin_init(
    FirebaseRemoteConfigPlugin* self) {
  self->event_channel = nullptr;
  self->listeners_map =
      new std::map<std::string,
                   firebase::remote_config::ConfigUpdateListenerRegistration>();
}

void firebase_remote_config_plugin_register_with_registrar(
    FlPluginRegistrar* registrar) {
  FirebaseRemoteConfigPlugin* plugin = FIREBASE_REMOTE_CONFIG_PLUGIN(
      g_object_new(firebase_remote_config_plugin_get_type(), nullptr));

  FlBinaryMessenger* messenger = fl_plugin_registrar_get_messenger(registrar);
  firebase_remote_config_firebase_remote_config_host_api_set_method_handlers(
      messenger, /* suffix= */ nullptr, &kFirebaseRemoteConfigHostApiVTable,
      g_object_ref(plugin), g_object_unref);

  // Set up EventChannel for config update listening
  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  plugin->event_channel = fl_event_channel_new(messenger, kEventChannelName,
                                               FL_METHOD_CODEC(codec));
  fl_event_channel_set_stream_handlers(
      plugin->event_channel, ConfigUpdateOnListen, ConfigUpdateOnCancel,
      g_object_ref(plugin), g_object_unref);

  g_object_unref(plugin);

  // Register for platform logging
  App::RegisterLibrary(kLibraryName,
                       firebase_remote_config_linux::getPluginVersion().c_str(),
                       nullptr);
}
