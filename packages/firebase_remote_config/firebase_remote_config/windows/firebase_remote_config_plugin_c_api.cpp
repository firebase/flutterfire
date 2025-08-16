#include "include/firebase_remote_config/firebase_remote_config_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "firebase_remote_config_plugin.h"

void FirebaseRemoteConfigPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  firebase_remote_config_windows::FirebaseRemoteConfigPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
