// Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#ifndef FLUTTER_FIREBASE_PLUGIN_H_
#define FLUTTER_FIREBASE_PLUGIN_H_

#include <flutter/encodable_value.h>

#include "firebase/app.h"

// Abstract interface mirroring Android's FlutterFirebasePlugin.java and iOS's
// FLTFirebasePlugin.h. Each Firebase plugin implements this to provide initial
// constants (e.g. current user) during Firebase.initializeApp().
class FlutterFirebasePlugin {
 public:
  virtual ~FlutterFirebasePlugin() {}

  // Returns a map of plugin-specific constants for the given Firebase app.
  // Called synchronously during initializeCore to populate pluginConstants.
  virtual flutter::EncodableMap GetPluginConstantsForFirebaseApp(
      const firebase::App& app) = 0;

  // Called when Firebase core is re-initialized, allowing plugins to reset
  // their state.
  virtual void DidReinitializeFirebaseCore() = 0;
};

#endif  // FLUTTER_FIREBASE_PLUGIN_H_
