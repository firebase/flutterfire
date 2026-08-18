/*
 * Copyright 2025, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

#ifndef FLUTTER_PLUGIN_FIREBASE_REMOTE_CONFIG_PLUGIN_H_
#define FLUTTER_PLUGIN_FIREBASE_REMOTE_CONFIG_PLUGIN_H_

#include <flutter/event_channel.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <map>
#include <memory>
#include <string>

#include "firebase/app.h"
#include "firebase/future.h"
#include "firebase/remote_config.h"
#include "firebase/remote_config/config_update_listener_registration.h"
#include "messages.g.h"

namespace firebase_remote_config_windows {

class ConfigUpdateStreamHandler;

class FirebaseRemoteConfigPlugin : public flutter::Plugin,
                                   public FirebaseRemoteConfigHostApi {
  friend class ConfigUpdateStreamHandler;

 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

  FirebaseRemoteConfigPlugin();

  virtual ~FirebaseRemoteConfigPlugin();

  // Disallow copy and assign.
  FirebaseRemoteConfigPlugin(const FirebaseRemoteConfigPlugin&) = delete;
  FirebaseRemoteConfigPlugin& operator=(const FirebaseRemoteConfigPlugin&) =
      delete;

  // FirebaseRemoteConfigHostApi methods.
  void Fetch(
      const std::string& app_name,
      std::function<void(std::optional<FlutterError> reply)> result) override;
  void FetchAndActivate(
      const std::string& app_name,
      std::function<void(ErrorOr<bool> reply)> result) override;
  void Activate(const std::string& app_name,
                std::function<void(ErrorOr<bool> reply)> result) override;
  void SetConfigSettings(
      const std::string& app_name, const RemoteConfigPigeonSettings& settings,
      std::function<void(std::optional<FlutterError> reply)> result) override;
  void SetDefaults(
      const std::string& app_name,
      const flutter::EncodableMap& default_parameters,
      std::function<void(std::optional<FlutterError> reply)> result) override;
  void EnsureInitialized(
      const std::string& app_name,
      std::function<void(std::optional<FlutterError> reply)> result) override;
  void SetCustomSignals(
      const std::string& app_name, const flutter::EncodableMap& custom_signals,
      std::function<void(std::optional<FlutterError> reply)> result) override;
  void GetAll(const std::string& app_name,
              std::function<void(ErrorOr<flutter::EncodableMap> reply)> result)
      override;
  void GetProperties(const std::string& app_name,
                     std::function<void(ErrorOr<flutter::EncodableMap> reply)>
                         result) override;

 private:
  static flutter::BinaryMessenger* binaryMessenger;
  static std::unique_ptr<flutter::EventChannel<flutter::EncodableValue>>
      event_channel_;
  static std::map<std::string,
                  firebase::remote_config::ConfigUpdateListenerRegistration>
      listeners_map_;
};

}  // namespace firebase_remote_config_windows

#endif  // FLUTTER_PLUGIN_FIREBASE_REMOTE_CONFIG_PLUGIN_H_
