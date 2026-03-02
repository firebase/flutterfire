// Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#ifndef FLUTTER_FIREBASE_PLUGIN_REGISTRY_H_
#define FLUTTER_FIREBASE_PLUGIN_REGISTRY_H_

#include <flutter/encodable_value.h>

#include <string>
#include <unordered_map>

#include "firebase/app.h"
#include "include/firebase_core/flutter_firebase_plugin.h"

namespace firebase_core_windows {

// Static registry that collects plugin constants from all registered Firebase
// plugins during initializeCore, mirroring Android's
// FlutterFirebasePluginRegistry.
class FlutterFirebasePluginRegistry {
 public:
  // Registers a plugin with the given channel name.
  static void RegisterPlugin(const std::string& channel_name,
                             FlutterFirebasePlugin* plugin);

  // Collects constants from all registered plugins for the given app.
  // Returns a map keyed by channel name, with each value being the plugin's
  // constants map.
  static flutter::EncodableMap GetPluginConstantsForFirebaseApp(
      const firebase::App& app);

  // Notifies all registered plugins that Firebase core was re-initialized.
  static void DidReinitializeFirebaseCore();

 private:
  static std::unordered_map<std::string, FlutterFirebasePlugin*>&
  GetRegisteredPlugins();
};

}  // namespace firebase_core_windows

#endif  // FLUTTER_FIREBASE_PLUGIN_REGISTRY_H_
