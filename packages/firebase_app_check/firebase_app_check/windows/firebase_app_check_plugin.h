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
class FlutterAppCheckProviderFactory;

// Custom App Check provider for Windows. When the Firebase C++ SDK calls
// GetToken(), this provider either calls into Dart via
// FirebaseAppCheckFlutterApi for a server-minted token, or forwards to the
// debug provider for the same app.
class FlutterAppCheckProvider : public firebase::app_check::AppCheckProvider {
 public:
  FlutterAppCheckProvider(flutter::BinaryMessenger* binary_messenger,
                          FlutterAppCheckProviderFactory* factory,
                          const std::string& app_name);
  void GetToken(std::function<void(firebase::app_check::AppCheckToken, int,
                                   const std::string&)>
                    completion_callback) override;

 private:
  std::unique_ptr<FirebaseAppCheckFlutterApi> flutter_api_;
  FlutterAppCheckProviderFactory* factory_;
  std::string app_name_;
};

// Long-lived factory that creates one FlutterAppCheckProvider per firebase
// App. CreateProvider is process-global in the C++ SDK, so this factory must
// outlive every AppCheck instance it is registered with.
class FlutterAppCheckProviderFactory
    : public firebase::app_check::AppCheckProviderFactory {
 public:
  explicit FlutterAppCheckProviderFactory(
      flutter::BinaryMessenger* binary_messenger);
  firebase::app_check::AppCheckProvider* CreateProvider(
      firebase::App* app) override;
  void SetAppUsesCustomProvider(const std::string& app_name, bool uses_custom);
  bool UsesCustomProvider(const std::string& app_name) const;

 private:
  flutter::BinaryMessenger* binary_messenger_;
  std::map<std::string, bool> custom_apps_;
  std::map<std::string, std::unique_ptr<FlutterAppCheckProvider>> providers_;
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
      const std::string* recaptcha_site_key,
      const std::string* windows_provider,
      std::function<void(std::optional<FlutterError> reply)> result) override;
  void GetToken(const std::string& app_name, bool force_refresh,
                std::function<void(ErrorOr<std::optional<std::string>> reply)>
                    result) override;
  void GetTokenResult(
      const std::string& app_name, bool force_refresh,
      std::function<
          void(ErrorOr<std::optional<InternalAppCheckTokenResult>> reply)>
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
  void EnsureProviderFactory();

  std::unique_ptr<FlutterAppCheckProviderFactory> provider_factory_;

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
