#include "firebase_core_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

#include "firebase/app.h"
#include "messages.g.h"

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <sstream>
#include <iostream>
#include <vector>
#include <future>
#include <stdexcept>
#include <string>
using ::firebase::App;

namespace firebase_core_windows {

// static
void FirebaseCorePlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {

  auto plugin = std::make_unique<FirebaseCorePlugin>();

  FirebaseCoreHostApi::SetUp(registrar->messenger(), plugin.get());

  registrar->AddPlugin(std::move(plugin));
}

FirebaseCorePlugin::FirebaseCorePlugin() {}

FirebaseCorePlugin::~FirebaseCorePlugin() = default;






// Convert a Pigeon FirebaseOptions to a Firebase Options.
firebase::AppOptions PigeonFirebaseOptionsToAppOptions(
  const PigeonFirebaseOptions& pigeon_options) {
  firebase::AppOptions options;
  options.set_api_key(pigeon_options.api_key().c_str());
  options.set_app_id(pigeon_options.app_id().c_str());
  options.set_database_url(pigeon_options.database_u_r_l()->c_str());
  options.set_messaging_sender_id(pigeon_options.messaging_sender_id().c_str());
  options.set_project_id(pigeon_options.project_id().c_str());
  options.set_storage_bucket(pigeon_options.storage_bucket()->c_str());
  options.set_ga_tracking_id(pigeon_options.tracking_id()->c_str());
  return options;
}

void FirebaseCorePlugin::InitializeApp(
    const std::string &app_name,
    const PigeonFirebaseOptions &initialize_app_request,
    std::function<void(ErrorOr<PigeonInitializeResponse> reply)> result) {
  // Create an app
  App *app;
  app = App::Create(PigeonFirebaseOptionsToAppOptions(initialize_app_request),
                    app_name.c_str());

  // Send back the result to Flutter
  result(PigeonInitializeResponse());

  // Log everything is OK
  std::cout << "FirebaseCorePlugin::InitializeApp: OK" << std::endl;      
}

void FirebaseCorePlugin::InitializeCore(
    std::function<void(ErrorOr<flutter::EncodableList> reply)> result) {
  result(flutter::EncodableList());
}

void FirebaseCorePlugin::OptionsFromResource(
    std::function<void(ErrorOr<PigeonFirebaseOptions> reply)> result) {}

void FirebaseCorePlugin::SetAutomaticDataCollectionEnabled(
    const std::string &app_name, bool enabled,
    std::function<void(std::optional<FlutterError> reply)> result) {
  App* firebaseApp = App::GetInstance(app_name.c_str());
  if (firebaseApp != nullptr) {
    // Missing method
  }
  result(std::nullopt);
}

void FirebaseCorePlugin::SetAutomaticResourceManagementEnabled(
    const std::string &app_name, bool enabled,
    std::function<void(std::optional<FlutterError> reply)> result) {
  App* firebaseApp = App::GetInstance(app_name.c_str());
  if (firebaseApp != nullptr) {
   // Missing method
  }

  result(std::nullopt);
}

void FirebaseCorePlugin::Delete(
    const std::string &app_name,
    std::function<void(std::optional<FlutterError> reply)> result) {
  App* firebaseApp = App::GetInstance(app_name.c_str());
  if (firebaseApp != nullptr) {
    // Missing method
  }

  result(std::nullopt);
}


}  // namespace firebase_core_windows
