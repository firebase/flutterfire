//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <firebase_core/firebase_core_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) firebase_core_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "FirebaseCorePlugin");
  firebase_core_plugin_register_with_registrar(firebase_core_registrar);
}
