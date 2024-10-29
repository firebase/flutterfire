//
// Created by Andrii on 13.01.2024.
//

#ifndef TODO_POINTS_FLUTTER_FIREBASE_PLUGIN_H
#define TODO_POINTS_FLUTTER_FIREBASE_PLUGIN_H

#include <string>
#include <flutter/encodable_value.h>
#include "firebase/app.h"

namespace firebase_core_windows {

    class FlutterFirebasePlugin {
    public:
        virtual std::string plugin_name() = 0;
        virtual flutter::EncodableMap get_plugin_constants(const ::firebase::App&) = 0;
    };
}

#endif //TODO_POINTS_FLUTTER_FIREBASE_PLUGIN_H
