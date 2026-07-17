// Copyright 2025, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "flutter_firebase_plugin_registry.h"

namespace firebase_core_linux {

std::unordered_map<std::string, FlutterFirebasePlugin*>&
FlutterFirebasePluginRegistry::GetRegisteredPlugins() {
  static std::unordered_map<std::string, FlutterFirebasePlugin*> plugins;
  return plugins;
}

void FlutterFirebasePluginRegistry::RegisterPlugin(
    const std::string& channel_name, FlutterFirebasePlugin* plugin) {
  GetRegisteredPlugins()[channel_name] = plugin;
}

FlValue* FlutterFirebasePluginRegistry::GetPluginConstantsForFirebaseApp(
    const firebase::App& app) {
  FlValue* all_constants = fl_value_new_map();
  for (const auto& entry : GetRegisteredPlugins()) {
    // GetPluginConstantsForFirebaseApp returns a new reference (transfer
    // full); fl_value_set_take assumes ownership of both key and value.
    FlValue* plugin_constants =
        entry.second->GetPluginConstantsForFirebaseApp(app);
    fl_value_set_take(all_constants, fl_value_new_string(entry.first.c_str()),
                      plugin_constants);
  }
  return all_constants;
}

void FlutterFirebasePluginRegistry::DidReinitializeFirebaseCore() {
  for (const auto& entry : GetRegisteredPlugins()) {
    entry.second->DidReinitializeFirebaseCore();
  }
}

}  // namespace firebase_core_linux
