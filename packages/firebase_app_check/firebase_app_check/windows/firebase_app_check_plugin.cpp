// Copyright 2025, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "firebase_app_check_plugin.h"

#include <flutter/event_channel.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>
#include <windows.h>

#include <future>
#include <memory>
#include <string>

#include "firebase/app.h"
#include "firebase/app_check.h"
#include "firebase/app_check/debug_provider.h"
#include "firebase/future.h"
#include "firebase_app_check/plugin_version.h"
#include "firebase_core/firebase_core_plugin_c_api.h"
#include "messages.g.h"

using ::firebase::App;
using ::firebase::Future;
using ::firebase::app_check::AppCheck;
using ::firebase::app_check::AppCheckListener;
using ::firebase::app_check::AppCheckToken;
using ::firebase::app_check::DebugAppCheckProviderFactory;

namespace firebase_app_check_windows {

static const std::string kLibraryName = "flutter-fire-app-check";
static const std::string kEventChannelNamePrefix =
    "plugins.flutter.io/firebase_app_check/token/";

flutter::BinaryMessenger* FirebaseAppCheckPlugin::binaryMessenger = nullptr;
std::map<std::string,
         std::unique_ptr<flutter::EventChannel<flutter::EncodableValue>>>
    FirebaseAppCheckPlugin::event_channels_;
std::map<std::string, firebase::app_check::AppCheckListener*>
    FirebaseAppCheckPlugin::listeners_map_;

// AppCheckListener implementation that forwards token changes to an EventSink.
class FlutterAppCheckListener : public AppCheckListener {
 public:
  void SetEventSink(
      std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> event_sink) {
    event_sink_ = std::move(event_sink);
  }

  void OnAppCheckTokenChanged(const AppCheckToken& token) override {
    if (event_sink_) {
      flutter::EncodableMap event;
      event[flutter::EncodableValue("token")] =
          flutter::EncodableValue(token.token);
      event_sink_->Success(flutter::EncodableValue(event));
    }
  }

 private:
  std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> event_sink_;
};

// StreamHandler for token change events.
class TokenStreamHandler
    : public flutter::StreamHandler<flutter::EncodableValue> {
 public:
  TokenStreamHandler(AppCheck* app_check, const std::string& app_name)
      : app_check_(app_check), app_name_(app_name) {}

  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
  OnListenInternal(
      const flutter::EncodableValue* arguments,
      std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events)
      override {
    listener_ = std::make_unique<FlutterAppCheckListener>();
    listener_->SetEventSink(std::move(events));
    app_check_->AddAppCheckListener(listener_.get());
    FirebaseAppCheckPlugin::listeners_map_[app_name_] = listener_.get();
    return nullptr;
  }

  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
  OnCancelInternal(const flutter::EncodableValue* arguments) override {
    if (listener_) {
      app_check_->RemoveAppCheckListener(listener_.get());
      FirebaseAppCheckPlugin::listeners_map_.erase(app_name_);
      listener_.reset();
    }
    return nullptr;
  }

 private:
  AppCheck* app_check_;
  std::string app_name_;
  std::unique_ptr<FlutterAppCheckListener> listener_;
};

// FlutterCustomAppCheckProvider calls into Dart via the FlutterApi and
// completes the Firebase C++ SDK callback asynchronously when Dart returns a
// token (or an error). The Dart handler returns the token together with its
// expiry, so the C++ SDK can cache for the exact lifetime the backend minted
// rather than a hardcoded refresh window.
FlutterCustomAppCheckProvider::FlutterCustomAppCheckProvider(
    flutter::BinaryMessenger* binary_messenger)
    : flutter_api_(
          std::make_unique<FirebaseAppCheckFlutterApi>(binary_messenger)) {}

void FlutterCustomAppCheckProvider::GetToken(
    std::function<void(firebase::app_check::AppCheckToken, int,
                       const std::string&)>
        completion_callback) {
  auto completion = std::make_shared<
      std::function<void(firebase::app_check::AppCheckToken, int,
                         const std::string&)>>(std::move(completion_callback));

  flutter_api_->GetCustomToken(
      [completion](const CustomAppCheckToken& dart_token) {
        firebase::app_check::AppCheckToken result_token;
        result_token.token = dart_token.token();
        result_token.expire_time_millis = dart_token.expire_time_millis();
        (*completion)(result_token, firebase::app_check::kAppCheckErrorNone,
                      "");
      },
      [completion](const FlutterError& error) {
        (*completion)(firebase::app_check::AppCheckToken(),
                      firebase::app_check::kAppCheckErrorUnknown,
                      error.message().empty() ? "unknown" : error.message());
      });
}

FlutterCustomAppCheckProviderFactory::FlutterCustomAppCheckProviderFactory(
    flutter::BinaryMessenger* binary_messenger)
    : binary_messenger_(binary_messenger) {}

firebase::app_check::AppCheckProvider*
FlutterCustomAppCheckProviderFactory::CreateProvider(firebase::App* app) {
  if (!provider_) {
    provider_ =
        std::make_unique<FlutterCustomAppCheckProvider>(binary_messenger_);
  }
  return provider_.get();
}

static AppCheck* GetAppCheckFromPigeon(const std::string& app_name) {
  App* app = App::GetInstance(app_name.c_str());
  return AppCheck::GetInstance(app);
}

static FlutterError ParseError(const firebase::FutureBase& completed_future) {
  std::string error_code = "unknown";
  int error = completed_future.error();
  switch (error) {
    case firebase::app_check::kAppCheckErrorServerUnreachable:
      error_code = "server-unreachable";
      break;
    case firebase::app_check::kAppCheckErrorInvalidConfiguration:
      error_code = "invalid-configuration";
      break;
    case firebase::app_check::kAppCheckErrorSystemKeychain:
      error_code = "system-keychain";
      break;
    case firebase::app_check::kAppCheckErrorUnsupportedProvider:
      error_code = "unsupported-provider";
      break;
    default:
      error_code = "unknown";
      break;
  }

  std::string error_message = completed_future.error_message()
                                  ? completed_future.error_message()
                                  : "An unknown error occurred";

  return FlutterError(error_code, error_message);
}

// static
void FirebaseAppCheckPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows* registrar) {
  auto plugin = std::make_unique<FirebaseAppCheckPlugin>();

  FirebaseAppCheckHostApi::SetUp(registrar->messenger(), plugin.get());

  registrar->AddPlugin(std::move(plugin));

  binaryMessenger = registrar->messenger();

  // Register for platform logging
  App::RegisterLibrary(kLibraryName.c_str(), getPluginVersion().c_str(),
                       nullptr);
}

FirebaseAppCheckPlugin::FirebaseAppCheckPlugin() {}

FirebaseAppCheckPlugin::~FirebaseAppCheckPlugin() {
  for (auto& [app_name, listener] : listeners_map_) {
    App* app = App::GetInstance(app_name.c_str());
    if (app) {
      AppCheck* app_check = AppCheck::GetInstance(app);
      if (app_check) {
        app_check->RemoveAppCheckListener(listener);
      }
    }
  }
  listeners_map_.clear();
  event_channels_.clear();
}

void FirebaseAppCheckPlugin::Activate(
    const std::string& app_name, const std::string* android_provider,
    const std::string* apple_provider, const std::string* debug_token,
    const std::string* windows_provider,
    std::function<void(std::optional<FlutterError> reply)> result) {
  if (windows_provider != nullptr && *windows_provider == "custom") {
    custom_provider_factory_ =
        std::make_unique<FlutterCustomAppCheckProviderFactory>(
            binaryMessenger);
    AppCheck::SetAppCheckProviderFactory(custom_provider_factory_.get());
  } else {
    DebugAppCheckProviderFactory* factory =
        DebugAppCheckProviderFactory::GetInstance();

    if (debug_token != nullptr && !debug_token->empty()) {
      factory->SetDebugToken(*debug_token);
    }

    AppCheck::SetAppCheckProviderFactory(factory);
  }
  result(std::nullopt);
}

void FirebaseAppCheckPlugin::GetToken(
    const std::string& app_name, bool force_refresh,
    std::function<void(ErrorOr<std::optional<std::string>> reply)> result) {
  AppCheck* app_check = GetAppCheckFromPigeon(app_name);

  Future<AppCheckToken> future = app_check->GetAppCheckToken(force_refresh);
  future.OnCompletion([result](const Future<AppCheckToken>& completed_future) {
    if (completed_future.error() != 0) {
      result(ParseError(completed_future));
    } else {
      const AppCheckToken* token = completed_future.result();
      if (token) {
        result(std::optional<std::string>(token->token));
      } else {
        result(std::optional<std::string>(std::nullopt));
      }
    }
  });
}

void FirebaseAppCheckPlugin::SetTokenAutoRefreshEnabled(
    const std::string& app_name, bool is_token_auto_refresh_enabled,
    std::function<void(std::optional<FlutterError> reply)> result) {
  AppCheck* app_check = GetAppCheckFromPigeon(app_name);
  app_check->SetTokenAutoRefreshEnabled(is_token_auto_refresh_enabled);
  result(std::nullopt);
}

void FirebaseAppCheckPlugin::RegisterTokenListener(
    const std::string& app_name,
    std::function<void(ErrorOr<std::string> reply)> result) {
  AppCheck* app_check = GetAppCheckFromPigeon(app_name);

  const std::string name = kEventChannelNamePrefix + app_name;

  auto event_channel =
      std::make_unique<flutter::EventChannel<flutter::EncodableValue>>(
          binaryMessenger, name, &flutter::StandardMethodCodec::GetInstance());
  event_channel->SetStreamHandler(
      std::make_unique<TokenStreamHandler>(app_check, app_name));

  event_channels_[app_name] = std::move(event_channel);

  result(name);
}

void FirebaseAppCheckPlugin::GetLimitedUseAppCheckToken(
    const std::string& app_name,
    std::function<void(ErrorOr<std::string> reply)> result) {
  // GetLimitedUseAppCheckToken was added to the Firebase C++ SDK after the
  // version currently bundled with this plugin. Fall back to GetAppCheckToken,
  // which is functionally equivalent for our custom Windows provider since it
  // does not cache — it calls getWindowsAppCheckToken on every invocation.
  AppCheck* app_check = GetAppCheckFromPigeon(app_name);
  Future<AppCheckToken> future = app_check->GetAppCheckToken(false);
  future.OnCompletion([result](const Future<AppCheckToken>& completed_future) {
    if (completed_future.error() != 0) {
      result(ParseError(completed_future));
    } else {
      const AppCheckToken* token = completed_future.result();
      if (token) {
        result(token->token);
      } else {
        result(FlutterError("unknown", "Failed to get limited use token"));
      }
    }
  });
}

}  // namespace firebase_app_check_windows
