#ifndef FLUTTER_PLUGIN_FIREBASE_CORE_PLUGIN_H_
#define FLUTTER_PLUGIN_FIREBASE_CORE_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace firebase_core {

class FirebaseCorePlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  FirebaseCorePlugin();

  virtual ~FirebaseCorePlugin();

  // Disallow copy and assign.
  FirebaseCorePlugin(const FirebaseCorePlugin &) = delete;
  FirebaseCorePlugin &operator=(const FirebaseCorePlugin &) = delete;

 private:
  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace firebase_core

#endif  // FLUTTER_PLUGIN_FIREBASE_CORE_PLUGIN_H_
