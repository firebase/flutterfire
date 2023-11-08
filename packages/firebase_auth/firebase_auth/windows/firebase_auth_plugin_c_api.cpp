// Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "include/firebase_auth/firebase_auth_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "firebase_auth_plugin.h"

void FirebaseAuthPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  firebase_auth_windows::FirebaseAuthPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
