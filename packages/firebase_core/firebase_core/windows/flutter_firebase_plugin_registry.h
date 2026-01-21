#ifndef FLUTTER_FIREBASE_PLUGIN_REGISTRY_H
#define FLUTTER_FIREBASE_PLUGIN_REGISTRY_H

#include <any>
#include <future>
#include <string>
#include <unordered_map>

#include "firebase/app.h"
#include "firebase/future.h"
#include "flutter_firebase_plugin.h"

namespace firebase_core_windows {

    class FlutterFirebasePluginRegistry {
    private:
        static std::unordered_map<std::string, FlutterFirebasePlugin*>
            registeredPlugins;

    public:
        static void registerPlugin(std::string channelName,
            FlutterFirebasePlugin* flutterFirebasePlugin);
        static flutter::EncodableMap getPluginConstantsForFirebaseApp(
            firebase::App firebaseApp);
        static firebase::Future<void> didReinitializeFirebaseCore();
    };

}

#endif  // FLUTTER_FIREBASE_PLUGIN_REGISTRY_H
