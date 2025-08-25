// Copyright 2025, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "firebase_remote_config_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>
#include <flutter/event_channel.h>
#include <flutter/event_stream_handler_functions.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <sstream>

#include "firebase/app.h"
#include "firebase/remote_config.h"
#include "firebase_core/firebase_plugin_registry.h"
#include "firebase_remote_config/plugin_version.h"
#include "firebase_remote_config_plugin_constants.h"
#include "messages.g.h"
// #include "remote_config_pigeon_implemetation.h"

using namespace firebase::remote_config;
using namespace firebase;

extern "C" firebase_core_windows::FirebasePluginRegistry *
GetFlutterFirebaseRegistry();

namespace firebase_remote_config_windows {
const char *kEventChannelName =
    "plugins.flutter.io/firebase_remote_config_updated";
const char *kMethodChannelName = "plugins.flutter.io/firebase_remote_config";
const char *kRemoteConfigLibrary = "firebase_remote_config_windows";
std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> sink_;

const char *kSetConfigSettingsMethodName = "RemoteConfig#setConfigSettings";
const char *kSetDefaultsMethodName = "RemoteConfig#setDefaults";
const char *kEnsureInitializedMethodName = "RemoteConfig#ensureInitialized";
const char *kFetchMethodName = "RemoteConfig#fetch";
const char *kActivateMethodName = "RemoteConfig#activate";
const char *kGetAllMethodName = "RemoteConfig#getAll";
const char *kGetPropertiesMethodName = "RemoteConfig#getProperties";
const char *kFetchAndActivateMethodName = "RemoteConfig#fetchAndActivate";

void FirebaseRemoteConfigPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto plugin = std::make_unique<FirebaseRemoteConfigPlugin>();

  FirebaseRemoteConfigHostApi::SetUp(registrar->messenger(), plugin.get());

  const auto firebase_registry =
      firebase_core_windows::FirebasePluginRegistry::GetInstance();
  const auto shared_plugin =
      std::make_shared<FlutterFirebaseRemoteConfigPlugin>();
  ::firebase::App::RegisterLibrary(kRemoteConfigLibrary,
                                   getPluginVersion().c_str(), nullptr);
  firebase_registry->put_plugin_ref(shared_plugin);

  const auto event_channel =
      std::make_unique<flutter::EventChannel<flutter::EncodableValue>>(
          registrar->messenger(), kEventChannelName,
          &flutter::StandardMethodCodec::GetInstance());

  auto eventChannelHandler = std::make_unique<
      flutter::StreamHandlerFunctions<flutter::EncodableValue>>(
      [&, plugin_pointer = plugin.get()](
          const flutter::EncodableValue *arguments,
          std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> sink)
          -> std::unique_ptr<
              flutter::StreamHandlerError<flutter::EncodableValue>> {
        // sink_ = std::move(sink);
        const auto args = plugin_pointer->try_get_arguments_(arguments);

        // Getting app name
        const auto app_name = plugin_pointer->get_app_name_(args);

        const auto firebaseApp = ::firebase::App::GetInstance(app_name.c_str());
        const auto remoteConfig =
            ::firebase::remote_config::RemoteConfig::GetInstance(firebaseApp);
        auto registration = remoteConfig->AddOnConfigUpdateListener(
            [&sink, this](ConfigUpdate &&config_update,
                          RemoteConfigError error) {
              const auto updatedKeys = config_update.updated_keys;
              flutter::EncodableList keys{};

              for (const auto &key : updatedKeys) {
                keys.push_back(flutter::EncodableValue(key));
              }
              sink->Success(flutter::EncodableValue(keys));
            });

        return nullptr;
      },
      [](const flutter::EncodableValue *arguments)
          -> std::unique_ptr<
              flutter::StreamHandlerError<flutter::EncodableValue>> {
        return nullptr;
      });

  event_channel->SetStreamHandler(std::move(eventChannelHandler));

  registrar->AddPlugin(std::move(plugin));
}

FirebaseRemoteConfigPlugin::FirebaseRemoteConfigPlugin() {}

FirebaseRemoteConfigPlugin::~FirebaseRemoteConfigPlugin() {}

std::vector<firebase::remote_config::ConfigKeyValueVariant>
FirebaseRemoteConfigPlugin::set_defaults_convert_to_native_(
    const flutter::EncodableMap &default_parameters) const {
  std::vector<ConfigKeyValueVariant> parameters;
  std::vector<std::pair<std::string, std::string>> storage;

  for (const auto &items : default_parameters) {
    if (std::holds_alternative<std::string>(items.first)) {
      std::string key_str = std::get<std::string>(items.first);

      ConfigKeyValueVariant kv;
      char *key = new char[key_str.size() + 1];
      // strcpy(key, key_str.c_str());
      strcpy_s(key, sizeof(char) * key_str.size() + 1, key_str.c_str());
      kv.key = key;
      kv.value = set_defaults_to_variant_(items.second);
      parameters.push_back(kv);
    }
  }

  return parameters;
}

firebase::Variant FirebaseRemoteConfigPlugin::set_defaults_to_variant_(
    flutter::EncodableValue encodableValue) const {
  if (std::holds_alternative<bool>(encodableValue)) {
    auto value = std::get<bool>(encodableValue);
    return {value};
  }

  if (std::holds_alternative<int64_t>(encodableValue)) {
    auto value = std::get<int64_t>(encodableValue);
    return {value};
  }

  if (std::holds_alternative<std::string>(encodableValue)) {
    auto value = std::get<std::string>(encodableValue);
    return {value};
  }

  if (std::holds_alternative<double>(encodableValue)) {
    auto value = std::get<double>(encodableValue);
    return {value};
  }

  return {};
}

std::string FirebaseRemoteConfigPlugin::map_last_fetch_status_(
    firebase::remote_config::LastFetchStatus lastFetchStatus) const {
  if (lastFetchStatus == kLastFetchStatusSuccess) {
    return "success";
  } else if (lastFetchStatus == kLastFetchStatusFailure) {
    return "failure";
  } else if (lastFetchStatus == kLastFetchStatusPending) {
    return "noFetchYet";
  } else {
    return "failure";
  }
}

flutter::EncodableMap *FirebaseRemoteConfigPlugin::try_get_arguments_(
    const flutter::EncodableValue *arguments) const {
  const auto args = std::get_if<flutter::EncodableMap>(arguments);
  return args ? const_cast<flutter::EncodableMap *>(args) : nullptr;
}

std::string FirebaseRemoteConfigPlugin::get_app_name_(
    flutter::EncodableMap *args) const {
  const auto &encodable_app_name_arg =
      args->find(flutter::EncodableValue("appName"));
  if (encodable_app_name_arg == args->end()) {
    throw std::exception("Arguments does not contains appName");
  }
  const auto &app_name_arg =
      std::get<std::string>(encodable_app_name_arg->second);

  return app_name_arg;
}

std::string FirebaseRemoteConfigPlugin::map_source_(ValueSource source) const {
  if (source == kValueSourceStaticValue) {
    return "static";
  } else if (source == kValueSourceDefaultValue) {
    return "default";
  } else if (source == kValueSourceRemoteValue) {
    return "remote";
  } else {
    return "static";
  }
}

flutter::EncodableMap
FirebaseRemoteConfigPlugin::create_remote_config_values_map_(
    std::string key, RemoteConfig *remote_config) const {
  flutter::EncodableMap parsed_parameters;

  ValueInfo value_info{};
  auto data = remote_config->GetData(key.c_str(), &value_info);

  parsed_parameters.insert(
      {flutter::EncodableValue("value"), flutter::EncodableValue(data)});
  const auto source_mapped = map_source_(value_info.source);
  parsed_parameters.insert({flutter::EncodableValue("source"),
                            flutter::EncodableValue(source_mapped.c_str())});
  return parsed_parameters;
}

flutter::EncodableMap FirebaseRemoteConfigPlugin::map_parameters_(
    std::map<std::string, firebase::Variant> parameters,
    RemoteConfig *remote_config) const {
  flutter::EncodableMap map_;

  for (const auto &val : parameters) {
    auto param = val.second;
    auto name = val.first;

    map_.insert({name, create_remote_config_values_map_(name, remote_config)});
  }

  return map_;
}

void FirebaseRemoteConfigPlugin::Fetch(
    const std::string &app_name,
    std::function<void(std::optional<FlutterError> reply)> result) {
  const auto firebaseApp = ::firebase::App::GetInstance(app_name.c_str());
  const auto remote_config = RemoteConfig::GetInstance(firebaseApp);

  auto future = remote_config->Fetch();

  future.OnCompletion([result](const Future<void> &futureResult) {
    if (futureResult.status() == kFutureStatusComplete) {
      result({});
    } else {
      result(FlutterError("Cannot fetch remote config"));
    }
  });
}

void FirebaseRemoteConfigPlugin::FetchAndActivate(
    const std::string &app_name,
    std::function<void(ErrorOr<bool> reply)> result) {

  const auto firebaseApp = ::firebase::App::GetInstance(app_name.c_str());
  const auto remote_config = RemoteConfig::GetInstance(firebaseApp);

  auto future = remote_config->FetchAndActivate();

  future.OnCompletion([result](const Future<bool> &futureResult) {
    if (futureResult.status() == kFutureStatusComplete) {
      auto operationResult = *futureResult.result();
      result(operationResult);
    } else {
      result(FlutterError("Cannot activate remote config"));
    }
  });
}

void FirebaseRemoteConfigPlugin::Activate(
    const std::string &app_name,
    std::function<void(ErrorOr<bool> reply)> result) {

  const auto firebaseApp = ::firebase::App::GetInstance(app_name.c_str());
  const auto remote_config = RemoteConfig::GetInstance(firebaseApp);

  auto future = remote_config->Activate();

  future.OnCompletion([result](const Future<bool> &futureResult) {
    if (futureResult.status() == kFutureStatusComplete) {
      auto operationResult = *futureResult.result();
      result(operationResult);
    } else {
      result(FlutterError("Cannot activate remote config"));
    }
  });
}

void FirebaseRemoteConfigPlugin::SetConfigSettings(
    const std::string &app_name, const RemoteConfigPigeonSettings &settings,
    std::function<void(std::optional<FlutterError> reply)> result) {
  const auto firebaseApp = App::GetInstance(app_name.c_str());
  const auto remoteConfig = RemoteConfig::GetInstance(firebaseApp);

  const ConfigSettings config_setting{
      static_cast<uint64_t>(settings.fetch_timeout_seconds()),
      static_cast<uint64_t>(settings.minimum_fetch_interval_seconds())};

  auto future = remoteConfig->SetConfigSettings(config_setting);

  future.OnCompletion([result](const Future<void> &futureResult) {
    if (futureResult.error() == kFutureStatusComplete) {
      result({});
    } else {
      result(FlutterError("Cannot set config settings"));
    }
  });
}

void FirebaseRemoteConfigPlugin::SetDefaults(
    const std::string &app_name,
    const flutter::EncodableMap &default_parameters,
    std::function<void(std::optional<FlutterError> reply)> result) {
  App *firebaseApp = App::GetInstance(app_name.c_str());
  RemoteConfig *remoteConfig = RemoteConfig::GetInstance(firebaseApp);

  const auto &default_args_native =
      set_defaults_convert_to_native_(default_parameters);

  auto future = remoteConfig->SetDefaults(default_args_native.data(),
                                          default_args_native.size());

  future.OnCompletion([result](const Future<void> &futureResult) {
    if (futureResult.error() == kFutureStatusComplete) {
      result({});
    } else {
      result(FlutterError("Cannot set defaults"));
    }
  });
}

void FirebaseRemoteConfigPlugin::EnsureInitialized(
    const std::string &app_name,
    std::function<void(std::optional<FlutterError> reply)> result) {
  const auto firebaseApp = ::firebase::App::GetInstance(app_name.c_str());
  const auto remote_config = RemoteConfig::GetInstance(firebaseApp);

  const auto future = remote_config->EnsureInitialized();

  future.OnCompletion([result](const Future<ConfigInfo> &futureResult) {
    if (futureResult.status() == kFutureStatusComplete) {
      result({});
    } else {
      result(
          FlutterError("Cannot initialize remote config"));
    }
  });
}

void FirebaseRemoteConfigPlugin::SetCustomSignals(
    const std::string &app_name, const flutter::EncodableMap &custom_signals,
    std::function<void(std::optional<FlutterError> reply)> result) {
  // No implementation in firebase cpp sdk yet
  result(std::nullopt);
}

void FirebaseRemoteConfigPlugin::GetAll(
    const std::string &app_name,
    std::function<void(ErrorOr<flutter::EncodableMap> reply)> result) {

  const auto firebaseApp = ::firebase::App::GetInstance(app_name.c_str());
  const auto remote_config = RemoteConfig::GetInstance(firebaseApp);

  const auto get_all = remote_config->GetAll();
  //
  auto all_mapped = map_parameters_(get_all, remote_config);
  result(all_mapped);
}

void FirebaseRemoteConfigPlugin::GetProperties(
    const std::string &app_name,
    std::function<void(ErrorOr<flutter::EncodableMap> reply)> result) {

  App *firebaseApp = App::GetInstance(app_name.c_str());
  RemoteConfig *remote_config = RemoteConfig::GetInstance(firebaseApp);

  const auto configSettings = remote_config->GetConfigSettings();
  auto fetchTimeout =
      static_cast<int64_t>(configSettings.fetch_timeout_in_milliseconds);
  auto minFetchTimeout = static_cast<int64_t>(
      configSettings.minimum_fetch_interval_in_milliseconds);

  const auto configInfo = remote_config->GetInfo();
  const auto lastFetch = static_cast<int64_t>(configInfo.fetch_time);
  const auto lastFetchStatus = configInfo.last_fetch_status;
  const auto lastFetchStatusMapped = map_last_fetch_status_(lastFetchStatus);
  //
  flutter::EncodableMap values;

  values.insert({flutter::EncodableValue("fetchTimeout"),
                 flutter::EncodableValue(fetchTimeout)});
  values.insert({flutter::EncodableValue("minimumFetchInterval"),
                 flutter::EncodableValue(minFetchTimeout)});
  values.insert({flutter::EncodableValue("lastFetchTime"),
                 flutter::EncodableValue(lastFetch)});
  values.insert({flutter::EncodableValue("lastFetchStatus"),
                 flutter::EncodableValue(lastFetchStatusMapped.c_str())});
  result(values);
}
}  // namespace firebase_remote_config_windows
