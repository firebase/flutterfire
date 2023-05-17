//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <firebase_core/firebase_core_plugin_c_api.h>
#include <firebase_remote_config/firebase_remote_config_plugin_c_api.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  FirebaseCorePluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FirebaseCorePluginCApi"));
  FirebaseRemoteConfigPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FirebaseRemoteConfigPluginCApi"));
}
