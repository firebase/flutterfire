// Copyright 2025, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "include/firebase_app_check/firebase_app_check_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "firebase_app_check_plugin.h"

void FirebaseAppCheckPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  firebase_app_check_windows::FirebaseAppCheckPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
