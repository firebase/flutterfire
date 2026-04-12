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

#include <functional>
#include <map>
#include <memory>
#include <string>

#include "firebase/app.h"
#include "firebase/app_check.h"
#include "firebase/future.h"
#include "messages.g.h"

namespace firebase_app_check_windows {

class TokenStreamHandler;

// Custom App Check provider for Windows. When the Firebase C++ SDK calls
// GetToken(), this provider calls into Dart via FirebaseAppCheckFlutterApi
// to request a server-minted token (from the getWindowsAppCheckToken Cloud
// Function), then completes the SDK callback with the result.
class FlutterCustomAppCheckProvider
    : public firebase::app_check::AppCheckProvider {
 public:
  explicit FlutterCustomAppCheckProvider(
      flutter::BinaryMessenger* binary_messenger);
  void GetToken(std::function<void(firebase::app_check::AppCheckToken, int,
                                   const std::string&)>
                    completion_callback) override;

 private:
  std::unique_ptr<FirebaseAppCheckFlutterApi> flutter_api_;
};

// Factory that creates FlutterCustomAppCheckProvider instances.
class FlutterCustomAppCheckProviderFactory
    : public firebase::app_check::AppCheckProviderFactory {
 public:
  explicit FlutterCustomAppCheckProviderFactory(
      flutter::BinaryMessenger* binary_messenger);
  firebase::app_check::AppCheckProvider* CreateProvider(
      firebase::App* app) override;

 private:
  flutter::BinaryMessenger* binary_messenger_;
  std::unique_ptr<FlutterCustomAppCheckProvider> provider_;
};

class FirebaseAppCheckPlugin : public flutter::Plugin,
                               public FirebaseAppCheckHostApi {
  friend class TokenStreamHandler;

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
      const std::string* windows_provider,
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
  // Holds ownership of the custom provider factory for its lifetime.
  // Must outlive the AppCheck instance it was registered with.
  std::unique_ptr<FlutterCustomAppCheckProviderFactory>
      custom_provider_factory_;

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
