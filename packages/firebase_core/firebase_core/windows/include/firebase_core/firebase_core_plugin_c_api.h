/*
 * Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

#ifndef FLUTTER_PLUGIN_FIREBASE_CORE_PLUGIN_C_API_H_
#define FLUTTER_PLUGIN_FIREBASE_CORE_PLUGIN_C_API_H_

#include <flutter_plugin_registrar.h>

#include <string>
#include <vector>

#include "flutter_firebase_plugin.h"

#ifdef FLUTTER_PLUGIN_IMPL
#define FLUTTER_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FLUTTER_PLUGIN_EXPORT __declspec(dllimport)
#endif

FLUTTER_PLUGIN_EXPORT void FirebaseCorePluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar);

// Registers a FlutterFirebasePlugin so that its constants are collected during
// Firebase.initializeApp(). The channel_name should match the Dart
// MethodChannel name (e.g. "plugins.flutter.io/firebase_auth").
FLUTTER_PLUGIN_EXPORT void RegisterFlutterFirebasePlugin(
    const std::string& channel_name, FlutterFirebasePlugin* plugin);

#endif  // FLUTTER_PLUGIN_FIREBASE_CORE_PLUGIN_C_API_H_
