//
// Created by Andrii on 13.01.2024.
//

#ifndef TODO_POINTS_FIREBASE_PLUGIN_REGISTRY_H
#define TODO_POINTS_FIREBASE_PLUGIN_REGISTRY_H

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
#endif //TODO_POINTS_FIREBASE_PLUGIN_REGISTRY_H