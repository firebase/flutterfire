// Copyright 2025, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "firebase_remote_config_plugin.h"

#include <flutter/event_channel.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>
#include <windows.h>

#include <future>
#include <map>
#include <memory>
#include <sstream>
#include <string>
#include <vector>

#include "firebase/app.h"
#include "firebase/future.h"
#include "firebase/remote_config.h"
#include "firebase/variant.h"
#include "firebase_core/firebase_core_plugin_c_api.h"
#include "firebase_remote_config/plugin_version.h"
#include "messages.g.h"

using ::firebase::App;
using ::firebase::Future;
using ::firebase::Variant;
using ::firebase::remote_config::ConfigInfo;
using ::firebase::remote_config::ConfigSettings;
using ::firebase::remote_config::RemoteConfig;

namespace firebase_remote_config_windows {

static std::string kLibraryName = "flutter-fire-rc";
flutter::BinaryMessenger* FirebaseRemoteConfigPlugin::binaryMessenger = nullptr;

// static
void FirebaseRemoteConfigPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows* registrar) {
  auto plugin = std::make_unique<FirebaseRemoteConfigPlugin>();

  FirebaseRemoteConfigHostApi::SetUp(registrar->messenger(), plugin.get());

  registrar->AddPlugin(std::move(plugin));

  binaryMessenger = registrar->messenger();

  // Register for platform logging
  App::RegisterLibrary(kLibraryName.c_str(), getPluginVersion().c_str(),
                       nullptr);
}

FirebaseRemoteConfigPlugin::FirebaseRemoteConfigPlugin() {}

FirebaseRemoteConfigPlugin::~FirebaseRemoteConfigPlugin() = default;

RemoteConfig* GetRemoteConfigFromPigeon(const std::string& app_name) {
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

static FlutterError ParseError(const firebase::FutureBase& completed_future) {
  std::string error_code = GetRemoteConfigErrorCode(completed_future.error());
  std::string error_message = completed_future.error_message()
                                  ? completed_future.error_message()
                                  : "An unknown error occurred";

  return FlutterError(error_code, error_message);
}

void FirebaseRemoteConfigPlugin::Fetch(
    const std::string& app_name,
    std::function<void(std::optional<FlutterError> reply)> result) {
  RemoteConfig* remote_config = GetRemoteConfigFromPigeon(app_name);

  Future<void> future = remote_config->Fetch();
  future.OnCompletion([result](const Future<void>& completed_future) {
    if (completed_future.error() != 0) {
      result(ParseError(completed_future));
    } else {
      result(std::nullopt);
    }
  });
}

void FirebaseRemoteConfigPlugin::FetchAndActivate(
    const std::string& app_name,
    std::function<void(ErrorOr<bool> reply)> result) {
  RemoteConfig* remote_config = GetRemoteConfigFromPigeon(app_name);

  Future<bool> future = remote_config->FetchAndActivate();
  future.OnCompletion([result](const Future<bool>& completed_future) {
    if (completed_future.error() != 0) {
      result(ParseError(completed_future));
    } else {
      bool activated = *completed_future.result();
      result(activated);
    }
  });
}

void FirebaseRemoteConfigPlugin::Activate(
    const std::string& app_name,
    std::function<void(ErrorOr<bool> reply)> result) {
  RemoteConfig* remote_config = GetRemoteConfigFromPigeon(app_name);

  Future<bool> future = remote_config->Activate();
  future.OnCompletion([result](const Future<bool>& completed_future) {
    if (completed_future.error() != 0) {
      result(ParseError(completed_future));
    } else {
      bool activated = *completed_future.result();
      result(activated);
    }
  });
}

void FirebaseRemoteConfigPlugin::SetConfigSettings(
    const std::string& app_name, const RemoteConfigPigeonSettings& settings,
    std::function<void(std::optional<FlutterError> reply)> result) {
  RemoteConfig* remote_config = GetRemoteConfigFromPigeon(app_name);

  ConfigSettings config_settings;
  config_settings.minimum_fetch_interval_in_milliseconds =
      settings.minimum_fetch_interval_seconds() * 1000;
  config_settings.fetch_timeout_in_milliseconds =
      settings.fetch_timeout_seconds() * 1000;

  Future<void> future = remote_config->SetConfigSettings(config_settings);
  future.OnCompletion([result](const Future<void>& completed_future) {
    if (completed_future.error() != 0) {
      result(ParseError(completed_future));
    } else {
      result(std::nullopt);
    }
  });
}

void FirebaseRemoteConfigPlugin::SetDefaults(
    const std::string& app_name,
    const flutter::EncodableMap& default_parameters,
    std::function<void(std::optional<FlutterError> reply)> result) {
  RemoteConfig* remote_config = GetRemoteConfigFromPigeon(app_name);

  // Convert EncodableMap to vector of ConfigKeyValueVariant
  std::vector<firebase::remote_config::ConfigKeyValueVariant> defaults;
  defaults.reserve(default_parameters.size());

  for (const auto& kv : default_parameters) {
    const std::string& key = std::get<std::string>(kv.first);
    Variant value;

    if (auto* str_val = std::get_if<std::string>(&kv.second)) {
      value = Variant(*str_val);
    } else if (auto* int_val = std::get_if<int32_t>(&kv.second)) {
      value = Variant(static_cast<int64_t>(*int_val));
    } else if (auto* long_val = std::get_if<int64_t>(&kv.second)) {
      value = Variant(*long_val);
    } else if (auto* double_val = std::get_if<double>(&kv.second)) {
      value = Variant(*double_val);
    } else if (auto* bool_val = std::get_if<bool>(&kv.second)) {
      value = Variant(*bool_val);
    } else {
      // For null or unsupported types, use empty string
      value = Variant("");
    }

    defaults.push_back({key.c_str(), value});
  }

  Future<void> future =
      remote_config->SetDefaults(defaults.data(), defaults.size());
  future.OnCompletion([result](const Future<void>& completed_future) {
    if (completed_future.error() != 0) {
      result(ParseError(completed_future));
    } else {
      result(std::nullopt);
    }
  });
}

void FirebaseRemoteConfigPlugin::EnsureInitialized(
    const std::string& app_name,
    std::function<void(std::optional<FlutterError> reply)> result) {
  RemoteConfig* remote_config = GetRemoteConfigFromPigeon(app_name);

  Future<ConfigInfo> future = remote_config->EnsureInitialized();
  future.OnCompletion([result](const Future<ConfigInfo>& completed_future) {
    if (completed_future.error() != 0) {
      result(ParseError(completed_future));
    } else {
      result(std::nullopt);
    }
  });
}

void FirebaseRemoteConfigPlugin::SetCustomSignals(
    const std::string& app_name, const flutter::EncodableMap& custom_signals,
    std::function<void(std::optional<FlutterError> reply)> result) {
  // SetCustomSignals is not supported on the C++ SDK for desktop platforms.
  result(FlutterError("unimplemented",
                      "SetCustomSignals is not supported on Windows."));
}

// Convert a Variant to its string representation, matching what the mobile
// SDKs return as raw bytes. Using GetAll() (which returns typed Variants)
// instead of GetString() ensures boolean values are correctly represented,
// as the C++ desktop SDK's GetString() may not handle boolean Variants
// properly.
static std::string VariantToString(const Variant& variant) {
  if (variant.is_bool()) {
    return variant.bool_value() ? "true" : "false";
  } else if (variant.is_int64()) {
    return std::to_string(variant.int64_value());
  } else if (variant.is_double()) {
    std::ostringstream oss;
    oss << variant.double_value();
    return oss.str();
  } else if (variant.is_string()) {
    return variant.string_value();
  } else if (variant.is_mutable_string()) {
    return variant.mutable_string();
  }
  return "";
}

void FirebaseRemoteConfigPlugin::GetAll(
    const std::string& app_name,
    std::function<void(ErrorOr<flutter::EncodableMap> reply)> result) {
  RemoteConfig* remote_config = GetRemoteConfigFromPigeon(app_name);

  // Use GetAll() to enumerate keys and detect value types via Variant.
  std::map<std::string, Variant> all_values = remote_config->GetAll();
  flutter::EncodableMap parameters;

  for (const auto& kv : all_values) {
    const std::string& key = kv.first;
    const Variant& variant = kv.second;

    firebase::remote_config::ValueInfo info;
    std::string str_value;

    if (variant.is_bool()) {
      // The desktop C++ SDK's Variant::bool_value() and GetString() may
      // return incorrect values for boolean parameters (e.g. "false" for
      // a value that is actually "true"). GetBoolean() correctly reads the
      // activated boolean value.
      bool bval = remote_config->GetBoolean(key.c_str(), &info);
      str_value = bval ? "true" : "false";
    } else {
      remote_config->GetString(key.c_str(), &info);
      str_value = VariantToString(variant);
    }

    std::vector<uint8_t> byte_data(str_value.begin(), str_value.end());

    flutter::EncodableMap value_map;
    value_map[flutter::EncodableValue("value")] =
        flutter::EncodableValue(byte_data);
    value_map[flutter::EncodableValue("source")] =
        flutter::EncodableValue(MapValueSource(info.source));

    parameters[flutter::EncodableValue(key)] =
        flutter::EncodableValue(value_map);
  }

  result(parameters);
}

void FirebaseRemoteConfigPlugin::GetProperties(
    const std::string& app_name,
    std::function<void(ErrorOr<flutter::EncodableMap> reply)> result) {
  RemoteConfig* remote_config = GetRemoteConfigFromPigeon(app_name);

  const ConfigInfo& info = remote_config->GetInfo();
  const ConfigSettings config_settings = remote_config->GetConfigSettings();

  int64_t fetch_timeout_seconds = static_cast<int64_t>(
      config_settings.fetch_timeout_in_milliseconds / 1000);
  int64_t minimum_fetch_interval_seconds = static_cast<int64_t>(
      config_settings.minimum_fetch_interval_in_milliseconds / 1000);
  int64_t last_fetch_time_millis = static_cast<int64_t>(info.fetch_time);

  flutter::EncodableMap properties;
  properties[flutter::EncodableValue("fetchTimeout")] =
      flutter::EncodableValue(fetch_timeout_seconds);
  properties[flutter::EncodableValue("minimumFetchInterval")] =
      flutter::EncodableValue(minimum_fetch_interval_seconds);
  properties[flutter::EncodableValue("lastFetchTime")] =
      flutter::EncodableValue(last_fetch_time_millis);
  properties[flutter::EncodableValue("lastFetchStatus")] =
      flutter::EncodableValue(MapLastFetchStatus(info.last_fetch_status));

  result(properties);
}

}  // namespace firebase_remote_config_windows
