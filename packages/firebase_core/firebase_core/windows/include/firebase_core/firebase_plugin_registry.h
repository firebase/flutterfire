/*
 * Copyright 2025, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

#ifndef FLUTTER_FIREBASE_PLUGIN_REGISTRY_H
#define FLUTTER_FIREBASE_PLUGIN_REGISTRY_H

#ifdef BUILDING_SHARED_DLL
#define DLL_EXPORT __declspec(dllexport)
#else
#define DLL_EXPORT __declspec(dllimport)
#endif

#include "../../messages.g.h"
#include "firebase/app.h"
#include <string>
#include <map>
#include "flutter_firebase_plugin.h"
#include <mutex>
#include <memory>
#include <time.h>
#include <vector>

namespace firebase_core_windows {

    class FirebasePluginRegistry {
    public:

        static FirebasePluginRegistry *GetInstance();

        void put_plugin_ref(std::shared_ptr <FlutterFirebasePlugin>);

        std::vector <std::shared_ptr<FlutterFirebasePlugin>> &p_constants();

        std::string app_name;

    private:
        FirebasePluginRegistry() {
            pConstants_ = {};
        }
        std::vector <std::shared_ptr<FlutterFirebasePlugin>> pConstants_;
        friend class FirebaseCorePlugin;
    };

}
#endif //FLUTTER_FIREBASE_PLUGIN_REGISTRY_H