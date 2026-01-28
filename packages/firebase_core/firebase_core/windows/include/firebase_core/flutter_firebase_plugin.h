/*
 * Copyright 2025, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */


#ifndef FLUTTER_FIREBASE_PLUGIN_H
#define FLUTTER_FIREBASE_PLUGIN_H

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

#endif //FLUTTER_FIREBASE_PLUGIN_H
