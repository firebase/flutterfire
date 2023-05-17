/*
 * Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

#ifndef FLUTTER_PLUGIN_FIREBASE_REMOTE_CONFIG_PLUGIN_H_
#define FLUTTER_PLUGIN_FIREBASE_REMOTE_CONFIG_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

#include "messages.g.h"

namespace firebase_remote_config_windows {

class FirebaseRemoteConfigPlugin : public flutter::Plugin,
                                   public FirebaseRemoteConfigHostApi {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

  FirebaseRemoteConfigPlugin();

  virtual ~FirebaseRemoteConfigPlugin();

  // Disallow copy and assign.
  FirebaseRemoteConfigPlugin(const FirebaseRemoteConfigPlugin&) = delete;
  FirebaseRemoteConfigPlugin& operator=(const FirebaseRemoteConfigPlugin&) =
      delete;

  // FirebaseRemoteConfigHostApi
  virtual void Activate(
      const PigeonFirebaseApp& app,
      std::function<void(ErrorOr<bool> reply)> result) override;
  virtual void EnsureInitialized(
      const PigeonFirebaseApp& app,
      std::function<void(std::optional<FlutterError> reply)> result) override;
  virtual void Fetch(
      const PigeonFirebaseApp& app,
      std::function<void(std::optional<FlutterError> reply)> result) override;
  virtual void FetchAndActivate(
      const PigeonFirebaseApp& app,
      std::function<void(ErrorOr<bool> reply)> result) override;

  virtual ErrorOr<flutter::EncodableMap> GetAll(
      const PigeonFirebaseApp& app) override;
  virtual ErrorOr<bool> GetBool(const PigeonFirebaseApp& app,
                                const std::string& key) override;
  virtual ErrorOr<int64_t> GetInt(const PigeonFirebaseApp& app,
                                  const std::string& key) override;
  virtual ErrorOr<double> GetDouble(const PigeonFirebaseApp& app,
                                    const std::string& key) override;
  virtual ErrorOr<std::string> GetString(const PigeonFirebaseApp& app,
                                         const std::string& key) override;
  virtual ErrorOr<PigeonRemoteConfigValue> GetValue(
      const PigeonFirebaseApp& app, const std::string& key) override;
  virtual void SetConfigSettings(
      const PigeonFirebaseApp& app,
      const PigeonRemoteConfigSettings& remote_config_settings,
      std::function<void(std::optional<FlutterError> reply)> result) override;
  virtual void SetDefaults(
      const PigeonFirebaseApp& app,
      const flutter::EncodableMap& default_parameters,
      std::function<void(std::optional<FlutterError> reply)> result) override;

 private:
  bool rcInitialized = false;
};

}  // namespace firebase_remote_config_windows

#endif  // FLUTTER_PLUGIN_FIREBASE_REMOTE_CONFIG_PLUGIN_H_
