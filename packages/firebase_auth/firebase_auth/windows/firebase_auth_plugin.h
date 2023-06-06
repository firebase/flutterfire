#ifndef FLUTTER_PLUGIN_FIREBASE_AUTH_PLUGIN_H_
#define FLUTTER_PLUGIN_FIREBASE_AUTH_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace firebase_auth {

class FirebaseAuthPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  FirebaseAuthPlugin();

  virtual ~FirebaseAuthPlugin();

  // Disallow copy and assign.
  FirebaseAuthPlugin(const FirebaseAuthPlugin&) = delete;
  FirebaseAuthPlugin& operator=(const FirebaseAuthPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace firebase_auth

#endif  // FLUTTER_PLUGIN_FIREBASE_AUTH_PLUGIN_H_
