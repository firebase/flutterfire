#ifndef FLUTTER_PLUGIN_FIREBASE_CORE_PLUGIN_H_
#define FLUTTER_PLUGIN_FIREBASE_CORE_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>
#include "messages.g.h"

namespace firebase_core_windows {

class FirebaseCorePlugin : public flutter::Plugin, public FirebaseCoreHostApi, public FirebaseAppHostApi {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  FirebaseCorePlugin();

  virtual ~FirebaseCorePlugin();

  // Disallow copy and assign.
  FirebaseCorePlugin(const FirebaseCorePlugin &) = delete;
  FirebaseCorePlugin &operator=(const FirebaseCorePlugin &) = delete;


  // FirebaseCoreHostApi
  virtual void InitializeApp(
      const std::string &app_name,
      const PigeonFirebaseOptions &initialize_app_request,
      std::function<void(ErrorOr<PigeonInitializeResponse> reply)> result) override;
  virtual void InitializeCore(
      std::function<void(ErrorOr<flutter::EncodableList> reply)> result)
      override;
  virtual void OptionsFromResource(
      std::function<void(ErrorOr<PigeonFirebaseOptions> reply)> result)
      override;


  // FirebaseAppHostApi
  virtual void SetAutomaticDataCollectionEnabled(
      const std::string &app_name, bool enabled,
      std::function<void(std::optional<FlutterError> reply)> result) override;
  virtual void SetAutomaticResourceManagementEnabled(
      const std::string &app_name, bool enabled,
      std::function<void(std::optional<FlutterError> reply)> result) override;
  virtual void Delete(
      const std::string &app_name,
      std::function<void(std::optional<FlutterError> reply)> result) override;



 private:

};

}  // namespace firebase_core

#endif  // FLUTTER_PLUGIN_FIREBASE_CORE_PLUGIN_H_
