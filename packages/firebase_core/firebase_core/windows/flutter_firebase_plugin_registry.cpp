#include "flutter_firebase_plugin_registry.h"

#include <any>
#include <exception>

#include "firebase/app.h"
#include "firebase/util.h"

#include "flutter/encodable_value.h"

namespace firebase_core_windows {

    std::unordered_map<std::string, FlutterFirebasePlugin*>
        FlutterFirebasePluginRegistry::registeredPlugins;

    void FlutterFirebasePluginRegistry::registerPlugin(
        std::string channelName, FlutterFirebasePlugin* flutterFirebasePlugin) {
        registeredPlugins[channelName] = flutterFirebasePlugin;
    }

    flutter::EncodableMap FlutterFirebasePluginRegistry::getPluginConstantsForFirebaseApp(
        firebase::App firebaseApp) {
        flutter::EncodableMap pluginConstants;

        for (const auto& entry : registeredPlugins) {
            std::string channelName = entry.first;
            FlutterFirebasePlugin* plugin = entry.second;

            firebase::Future future =
                plugin->getPluginConstantsForFirebaseApp(firebaseApp);
        }

        return pluginConstants;
    }
}