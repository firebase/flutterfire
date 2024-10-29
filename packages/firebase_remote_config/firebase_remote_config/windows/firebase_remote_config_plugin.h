#ifndef FLUTTER_PLUGIN_FIREBASE_REMOTE_CONFIG_PLUGIN_H_
#define FLUTTER_PLUGIN_FIREBASE_REMOTE_CONFIG_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include "firebase_core/flutter_firebase_plugin.h"
#include <memory>

namespace firebase_remote_config_windows {

    class FirebaseRemoteConfigPlugin : public flutter::Plugin{
    public:
        static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

        FirebaseRemoteConfigPlugin();

        virtual ~FirebaseRemoteConfigPlugin();

        // Disallow copy and assign.
        FirebaseRemoteConfigPlugin(const FirebaseRemoteConfigPlugin &) = delete;

        FirebaseRemoteConfigPlugin &operator=(const FirebaseRemoteConfigPlugin &) = delete;

        // Called when a method is called on this plugin's channel from Dart.
        void HandleMethodCall(
                const flutter::MethodCall <flutter::EncodableValue> &method_call,
                std::unique_ptr <flutter::MethodResult<flutter::EncodableValue>> result);
    };

}  // namespace firebase_remote_config

#endif  // FLUTTER_PLUGIN_FIREBASE_REMOTE_CONFIG_PLUGIN_H_
