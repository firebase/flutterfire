// Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "firebase_core_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

#include "firebase/app.h"
#include "firebase_core/plugin_version.h"
#include "messages.g.h"

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <future>
#include <iostream>
#include <map>
#include <memory>
#include <sstream>
#include <stdexcept>
#include <string>
#include <vector>

using ::firebase::App;

namespace firebase_core_windows {

static std::string kLibraryName = "flutter-fire-core";

// static
void FirebaseCorePlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows* registrar) {
  auto plugin = std::make_unique<FirebaseCorePlugin>();

  FirebaseCoreHostApi::SetUp(registrar->messenger(), plugin.get());
  FirebaseAppHostApi::SetUp(registrar->messenger(), plugin.get());

  registrar->AddPlugin(std::move(plugin));

  // Register for platform logging
  App::RegisterLibrary(kLibraryName.c_str(), getPluginVersion().c_str(),
                       nullptr);
}

FirebaseCorePlugin::FirebaseCorePlugin() {}

FirebaseCorePlugin::~FirebaseCorePlugin() = default;

// Convert a CoreFirebaseOptions to a Firebase Options.
firebase::AppOptions CoreFirebaseOptionsToAppOptions(
    const CoreFirebaseOptions& pigeon_options) {
  firebase::AppOptions options;
  options.set_api_key(pigeon_options.api_key().c_str());
  options.set_app_id(pigeon_options.app_id().c_str());
  if (pigeon_options.database_u_r_l() != nullptr) {
    options.set_database_url(pigeon_options.database_u_r_l()->c_str());
  }
  if (pigeon_options.tracking_id() != nullptr) {
    options.set_ga_tracking_id(pigeon_options.tracking_id()->c_str());
  }
  options.set_messaging_sender_id(pigeon_options.messaging_sender_id().c_str());

  options.set_project_id(pigeon_options.project_id().c_str());

  if (pigeon_options.storage_bucket() != nullptr) {
    options.set_storage_bucket(pigeon_options.storage_bucket()->c_str());
  }
  return options;
}

// Convert a AppOptions to CoreFirebaseOptions
CoreFirebaseOptions optionsFromFIROptions(const firebase::AppOptions& options) {
  CoreFirebaseOptions pigeon_options =
      CoreFirebaseOptions(options.api_key(), options.app_id(),
                          options.messaging_sender_id(), options.project_id());
  // AppOptions initialises as empty char so we check to stop empty string to
  // Flutter Same for storage bucket below
  const char* db_url = options.database_url();
  if (db_url != nullptr && db_url[0] != '\0') {
    pigeon_options.set_database_u_r_l(db_url);
  }
  pigeon_options.set_tracking_id(nullptr);

  const char* storage_bucket = options.storage_bucket();
  if (storage_bucket != nullptr && storage_bucket[0] != '\0') {
    pigeon_options.set_storage_bucket(storage_bucket);
  }
  return pigeon_options;
}

// Convert a firebase::App to CoreInitializeResponse
CoreInitializeResponse AppToCoreInitializeResponse(const App& app) {
  flutter::EncodableMap plugin_constants;
  CoreInitializeResponse response = CoreInitializeResponse(
      app.name(), optionsFromFIROptions(app.options()), plugin_constants);
  return response;
}

void FirebaseCorePlugin::InitializeApp(
    const std::string& app_name,
    const CoreFirebaseOptions& initialize_app_request,
    std::function<void(ErrorOr<CoreInitializeResponse> reply)> result) {
  // Create an app
  App* app =
      App::Create(CoreFirebaseOptionsToAppOptions(initialize_app_request),
                  app_name.c_str());

  // Send back the result to Flutter
  result(AppToCoreInitializeResponse(*app));
}

void FirebaseCorePlugin::InitializeCore(
    std::function<void(ErrorOr<flutter::EncodableList> reply)> result) {
  // TODO: Missing function to get the list of currently initialized apps
  std::vector<CoreInitializeResponse> initializedApps;
  std::vector<App*> all_apps = App::GetApps();
  for (const App* app : all_apps) {
    initializedApps.push_back(AppToCoreInitializeResponse(*app));
  }

  flutter::EncodableList encodableList;

  for (const auto& item : initializedApps) {
    encodableList.push_back(flutter::CustomEncodableValue(item));
  }
  result(encodableList);
}

void FirebaseCorePlugin::OptionsFromResource(
    std::function<void(ErrorOr<CoreFirebaseOptions> reply)> result) {}

void FirebaseCorePlugin::SetAutomaticDataCollectionEnabled(
    const std::string& app_name, bool enabled,
    std::function<void(std::optional<FlutterError> reply)> result) {
  App* firebaseApp = App::GetInstance(app_name.c_str());
  if (firebaseApp != nullptr) {
    // TODO: Missing method
  }
  result(std::nullopt);
}

void FirebaseCorePlugin::SetAutomaticResourceManagementEnabled(
    const std::string& app_name, bool enabled,
    std::function<void(std::optional<FlutterError> reply)> result) {
  App* firebaseApp = App::GetInstance(app_name.c_str());
  if (firebaseApp != nullptr) {
    // TODO: Missing method
  }

  result(std::nullopt);
}

void FirebaseCorePlugin::Delete(
    const std::string& app_name,
    std::function<void(std::optional<FlutterError> reply)> result) {
  App* firebaseApp = App::GetInstance(app_name.c_str());
  if (firebaseApp != nullptr) {
    // TODO: Missing method
  }

  result(std::nullopt);
}

}  // namespace firebase_core_windows
