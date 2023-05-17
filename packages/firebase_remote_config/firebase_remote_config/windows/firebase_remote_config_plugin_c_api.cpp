// Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "include/firebase_remote_config/firebase_remote_config_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "firebase_remote_config_plugin.h"

void FirebaseRemoteConfigPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  firebase_remote_config_windows::FirebaseRemoteConfigPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
