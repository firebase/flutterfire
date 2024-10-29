//
// Created by Andrii on 29.10.2024.
//

#ifndef WINDOWS_FIREBASE_REMOTE_CONFIG_PLUGIN_CONSTANTS_H
#define WINDOWS_FIREBASE_REMOTE_CONFIG_PLUGIN_CONSTANTS_H

#include "firebase_core/flutter_firebase_plugin.h"

namespace firebase_remote_config_windows {
    class FlutterFirebaseRemoteConfigPlugin : public firebase_core_windows::FlutterFirebasePlugin {
        public:
            FlutterFirebaseRemoteConfigPlugin() {}
    //        virtual ~FirebaseRemoteConfigImplementation() override {}

            virtual std::string plugin_name() override;

            virtual flutter::EncodableMap get_plugin_constants(const ::firebase::App &) override;

        private:
            std::string app_name_;
    };

}
#endif //WINDOWS_FIREBASE_REMOTE_CONFIG_PLUGIN_CONSTANTS_H
