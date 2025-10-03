/*
 * Copyright 2025, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

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
