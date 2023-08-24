#include "include/cloud_firestore/cloud_firestore_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "cloud_firestore_plugin.h"

void CloudFirestorePluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  cloud_firestore::CloudFirestorePlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
