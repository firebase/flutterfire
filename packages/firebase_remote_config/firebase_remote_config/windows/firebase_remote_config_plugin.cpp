// Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
#define _CRT_SECURE_NO_WARNINGS
#include "firebase_remote_config_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

#include "firebase/app.h"
#include "firebase/future.h"
#include "firebase/remote_config.h"
#include "firebase_core/firebase_core_plugin_c_api.h"
#include "messages.g.h"

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>
#include <Windows.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

// #include <chrono>
#include <future>
#include <iostream>
#include <memory>
#include <sstream>
#include <stdexcept>
#include <string>
// #include <thread>
#include <vector>
using ::firebase::App;
using ::firebase::Future;
using ::firebase::remote_config::RemoteConfig;

namespace firebase_remote_config_windows {

// static
void FirebaseRemoteConfigPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows* registrar) {
  auto plugin = std::make_unique<FirebaseRemoteConfigPlugin>();

  FirebaseRemoteConfigHostApi::SetUp(registrar->messenger(), plugin.get());

  registrar->AddPlugin(std::move(plugin));
}

FirebaseRemoteConfigPlugin::FirebaseRemoteConfigPlugin() {}

FirebaseRemoteConfigPlugin::~FirebaseRemoteConfigPlugin() = default;

RemoteConfig* GetRCFromPigeon(const PigeonFirebaseApp& pigeonApp) {
  void* rc_ptr = GetFirebaseRemoteConfig(pigeonApp.app_name());
  RemoteConfig* rc = static_cast<RemoteConfig*>(rc_ptr);

  return rc;
}

void FirebaseRemoteConfigPlugin::Activate(
    const PigeonFirebaseApp& app,
    std::function<void(ErrorOr<bool> reply)> result) {
  RemoteConfig* rc = GetRCFromPigeon(app);

  Future<bool> activated_result = rc->Activate();
  activated_result.OnCompletion([result](const Future<bool>& bool_result) {
    // TODO error handling
    result(bool_result.result());
    std::cout << "[C++] FirebaseRemoteConfigPlugin::Activate() COMPLETE"
              << std::endl;
  });
}

void FirebaseRemoteConfigPlugin::EnsureInitialized(
    const PigeonFirebaseApp& app,
    std::function<void(std::optional<FlutterError> reply)> result) {
  RemoteConfig* rc = GetRCFromPigeon(app);

  Future<::firebase::remote_config::ConfigInfo> init_result =
      rc->EnsureInitialized();
}

void FirebaseRemoteConfigPlugin::Fetch(
    const PigeonFirebaseApp& app,
    std::function<void(std::optional<FlutterError> reply)> result) {
  RemoteConfig* rc = GetRCFromPigeon(app);

  Future<void> fetch_result = rc->Fetch();
  fetch_result.OnCompletion([result](const Future<void>& void_result) {
    // TODO error handling
    std::cout << "[C++] FirebaseRemoteConfigPlugin::Fetch() COMPLETE"
              << std::endl;
    result(std::nullopt);
  });
}

void FirebaseRemoteConfigPlugin::FetchAndActivate(
    const PigeonFirebaseApp& app,
    std::function<void(ErrorOr<bool> reply)> result) {
  RemoteConfig* rc = GetRCFromPigeon(app);

  Future<bool> fa_result = rc->FetchAndActivate();
  std::cout << "[C++] rc->FetchAndActivate()" << std::endl;
  fa_result.OnCompletion([result](const Future<bool>& bool_result) {
    // TODO error handling
    result(bool_result.result());
    std::cout << "[C++] FirebaseRemoteConfigPlugin::FetchAndActivate() COMPLETE"
              << std::endl;
  });
}

ErrorOr<flutter::EncodableMap> FirebaseRemoteConfigPlugin::GetAll(
    const PigeonFirebaseApp& app) {
  return flutter::EncodableMap();
}

ErrorOr<bool> FirebaseRemoteConfigPlugin::GetBool(const PigeonFirebaseApp& app,
                                                  const std::string& key) {
  RemoteConfig* rc = GetRCFromPigeon(app);

  return rc->GetBoolean(key.c_str());
}

ErrorOr<int64_t> FirebaseRemoteConfigPlugin::GetInt(
    const PigeonFirebaseApp& app, const std::string& key) {
  RemoteConfig* rc = GetRCFromPigeon(app);

  return rc->GetLong(key.c_str());
}

ErrorOr<double> FirebaseRemoteConfigPlugin::GetDouble(
    const PigeonFirebaseApp& app, const std::string& key) {
  RemoteConfig* rc = GetRCFromPigeon(app);

  return rc->GetDouble(key.c_str());
}

ErrorOr<std::string> FirebaseRemoteConfigPlugin::GetString(
    const PigeonFirebaseApp& app, const std::string& key) {
  RemoteConfig* rc = GetRCFromPigeon(app);

  return rc->GetString(key.c_str());
}

ErrorOr<PigeonRemoteConfigValue> FirebaseRemoteConfigPlugin::GetValue(
    const PigeonFirebaseApp& app, const std::string& key) {
  // RemoteConfig* rc = GetRCFromPigeon(app);

  // std::vector<unsigned char> data = rc->GetData(key.c_str());

  PigeonRemoteConfigValue* value_ptr =
      new PigeonRemoteConfigValue(PigeonValueSource::valueStatic);
  return *value_ptr;
}

void FirebaseRemoteConfigPlugin::SetConfigSettings(
    const PigeonFirebaseApp& app,
    const PigeonRemoteConfigSettings& remote_config_settings,
    std::function<void(std::optional<FlutterError> reply)> result) {
  // TODO
  std::cout << "[C++] FirebaseRemoteConfigPlugin::SetConfigSettings()"
            << std::endl;
  result(std::nullopt);
}

void FirebaseRemoteConfigPlugin::SetDefaults(
    const PigeonFirebaseApp& app,
    const flutter::EncodableMap& default_parameters,
    std::function<void(std::optional<FlutterError> reply)> result) {
  // TODO
  result(std::nullopt);
}

}  // namespace firebase_remote_config_windows
