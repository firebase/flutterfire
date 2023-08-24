#ifndef FLUTTER_PLUGIN_CLOUD_FIRESTORE_PLUGIN_H_
#define FLUTTER_PLUGIN_CLOUD_FIRESTORE_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace cloud_firestore {

class CloudFirestorePlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  CloudFirestorePlugin();

  virtual ~CloudFirestorePlugin();

  // Disallow copy and assign.
  CloudFirestorePlugin(const CloudFirestorePlugin&) = delete;
  CloudFirestorePlugin& operator=(const CloudFirestorePlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace cloud_firestore

#endif  // FLUTTER_PLUGIN_CLOUD_FIRESTORE_PLUGIN_H_
