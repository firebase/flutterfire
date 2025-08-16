//
// Created by Andrii on 13.01.2024.
//

#include "include/firebase_core/firebase_plugin_registry.h"
#include "firebase/app.h"

extern firebase_core_windows::FirebasePluginRegistry* registry_instance_  = nullptr;

namespace firebase_core_windows {

    FirebasePluginRegistry* FirebasePluginRegistry::GetInstance() {
        if (registry_instance_ == nullptr) {
            registry_instance_ = new FirebasePluginRegistry();
        }

        return registry_instance_;
    }

    void FirebasePluginRegistry::put_plugin_ref(std::shared_ptr<FlutterFirebasePlugin> plugin) {
        this->pConstants_.push_back(plugin);
    }

    std::vector<std::shared_ptr<FlutterFirebasePlugin>>& FirebasePluginRegistry::p_constants() {
        return pConstants_;
    }
}