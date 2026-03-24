/*
 * Copyright 2025, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

#ifndef FLUTTER_PLUGIN_FIREBASE_APP_CHECK_PLUGIN_H_
#define FLUTTER_PLUGIN_FIREBASE_APP_CHECK_PLUGIN_H_

#include <flutter/event_channel.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <map>
#include <memory>
#include <string>

#include "firebase/app.h"
#include "firebase/app_check.h"
#include "firebase/future.h"
#include "messages.g.h"

namespace firebase_app_check_windows {

class FirebaseAppCheckPlugin : public flutter::Plugin,
                               public FirebaseAppCheckHostApi {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

  FirebaseAppCheckPlugin();

  virtual ~FirebaseAppCheckPlugin();

  // Disallow copy and assign.
  FirebaseAppCheckPlugin(const FirebaseAppCheckPlugin&) = delete;
  FirebaseAppCheckPlugin& operator=(const FirebaseAppCheckPlugin&) = delete;

  // FirebaseAppCheckHostApi methods.
  void Activate(
      const std::string& app_name, const std::string* android_provider,
      const std::string* apple_provider, const std::string* debug_token,
      std::function<void(std::optional<FlutterError> reply)> result) override;
  void GetToken(const std::string& app_name, bool force_refresh,
                std::function<void(ErrorOr<std::optional<std::string>> reply)>
                    result) override;
  void SetTokenAutoRefreshEnabled(
      const std::string& app_name, bool is_token_auto_refresh_enabled,
      std::function<void(std::optional<FlutterError> reply)> result) override;
  void RegisterTokenListener(
      const std::string& app_name,
      std::function<void(ErrorOr<std::string> reply)> result) override;
  void GetLimitedUseAppCheckToken(
      const std::string& app_name,
      std::function<void(ErrorOr<std::string> reply)> result) override;

 private:
  static flutter::BinaryMessenger* binaryMessenger;
  static std::map<
      std::string,
      std::unique_ptr<flutter::EventChannel<flutter::EncodableValue>>>
      event_channels_;
  static std::map<std::string, firebase::app_check::AppCheckListener*>
      listeners_map_;
};

}  // namespace firebase_app_check_windows

#endif  // FLUTTER_PLUGIN_FIREBASE_APP_CHECK_PLUGIN_H_
