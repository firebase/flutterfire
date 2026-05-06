// Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "flutter_firebase_plugin_registry.h"

namespace firebase_core_windows {

std::unordered_map<std::string, FlutterFirebasePlugin*>&
FlutterFirebasePluginRegistry::GetRegisteredPlugins() {
  static std::unordered_map<std::string, FlutterFirebasePlugin*> plugins;
  return plugins;
}

void FlutterFirebasePluginRegistry::RegisterPlugin(
    const std::string& channel_name, FlutterFirebasePlugin* plugin) {
  GetRegisteredPlugins()[channel_name] = plugin;
}

flutter::EncodableMap
FlutterFirebasePluginRegistry::GetPluginConstantsForFirebaseApp(
    const firebase::App& app) {
  flutter::EncodableMap all_constants;
  for (const auto& entry : GetRegisteredPlugins()) {
    flutter::EncodableMap plugin_constants =
        entry.second->GetPluginConstantsForFirebaseApp(app);
    all_constants[flutter::EncodableValue(entry.first)] =
        flutter::EncodableValue(plugin_constants);
  }
  return all_constants;
}

void FlutterFirebasePluginRegistry::DidReinitializeFirebaseCore() {
  for (const auto& entry : GetRegisteredPlugins()) {
    entry.second->DidReinitializeFirebaseCore();
  }
}

}  // namespace firebase_core_windows
