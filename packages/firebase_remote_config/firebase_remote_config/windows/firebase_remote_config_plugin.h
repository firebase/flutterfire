/*
 * Copyright 2025, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

#ifndef FLUTTER_PLUGIN_FIREBASE_REMOTE_CONFIG_PLUGIN_H_
#define FLUTTER_PLUGIN_FIREBASE_REMOTE_CONFIG_PLUGIN_H_

#include <firebase/remote_config.h>
#include <firebase/variant.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

#include "firebase_core/flutter_firebase_plugin.h"

namespace firebase {
namespace remote_config {
struct ConfigKeyValueVariant;
}
}

namespace firebase_remote_config_windows {

class FirebaseRemoteConfigException : public std::exception {
 public:
  explicit FirebaseRemoteConfigException(std::string message)
      : message_(std::move(message)) {}

  const char *what() const noexcept override { return message_.c_str(); }

 private:
  std::string message_;
};

class FirebaseRemoteConfigPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  FirebaseRemoteConfigPlugin();

  virtual ~FirebaseRemoteConfigPlugin();

  // Disallow copy and assign.
  FirebaseRemoteConfigPlugin(const FirebaseRemoteConfigPlugin &) = delete;

  FirebaseRemoteConfigPlugin &operator=(const FirebaseRemoteConfigPlugin &) =
      delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

 private:
  void get_method_channel_arguments_(flutter::EncodableMap *args) const;
  // bool set_defaults_(const std::string &app_name,
  //                    const flutter::EncodableMap &args) const;
  std::vector<firebase::remote_config::ConfigKeyValueVariant> set_defaults_convert_to_native_(
      const flutter::EncodableMap &default_parameters) const;
  firebase::Variant set_defaults_to_variant_(flutter::EncodableValue encodableValue) const;
  std::string map_last_fetch_status_(firebase::remote_config::LastFetchStatus lastFetchStatus) const;
  flutter::EncodableMap *try_get_arguments_(const flutter::EncodableValue *arguments) const;
  std::string get_app_name_(flutter::EncodableMap *encodable_map) const;
  flutter::EncodableMap get_all_(
      const flutter::EncodableValue *arguments) const;
  std::string map_source_(firebase::remote_config::ValueSource source) const;
  flutter::EncodableMap create_remote_config_values_map_(
      std::string key, firebase::remote_config::RemoteConfig *remote_config) const;
  flutter::EncodableMap map_parameters_(
      std::map<std::string, firebase::Variant> parameters,
      firebase::remote_config::RemoteConfig *remote_config) const;
  void set_config_settings_(
      const flutter::EncodableValue *arguments,
      std::function<void(std::optional<FirebaseRemoteConfigException>)>
          completion);
  void set_defaults_(const flutter::EncodableValue *arguments,
      std::function<void(std::optional<FirebaseRemoteConfigException>)>
          completion);
  flutter::EncodableMap get_properties_(const flutter::EncodableValue *arguments);
  void ensure_initialized_(const flutter::EncodableValue *arguments,
      std::function<void(std::optional<FirebaseRemoteConfigException>)>
          completion);
  void activate_(const flutter::EncodableValue *arguments,
    std::function<void(std::variant<bool, FirebaseRemoteConfigException>)> completion);
  void fetch_(
      const flutter::EncodableValue *arguments,
      std::function<void(std::optional<FirebaseRemoteConfigException>)>
          completion);
  void fetch_and_activate_(
      const flutter::EncodableValue *arguments,
      std::function<void(std::variant<bool, FirebaseRemoteConfigException>)>
          completion);
};

}  // namespace firebase_remote_config_windows

#endif  // FLUTTER_PLUGIN_FIREBASE_REMOTE_CONFIG_PLUGIN_H_
