// Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "include/cloud_firestore/cloud_firestore_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "cloud_firestore_plugin.h"

void CloudFirestorePluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  cloud_firestore_windows::CloudFirestorePlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
