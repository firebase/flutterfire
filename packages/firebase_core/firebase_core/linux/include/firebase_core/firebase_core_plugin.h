/*
 * Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

#ifndef FLUTTER_PLUGIN_FIREBASE_CORE_PLUGIN_H_
#define FLUTTER_PLUGIN_FIREBASE_CORE_PLUGIN_H_

#include <flutter_linux/flutter_linux.h>

G_BEGIN_DECLS

#ifdef FLUTTER_PLUGIN_IMPL
#define FLUTTER_PLUGIN_EXPORT __attribute__((visibility("default")))
#else
#define FLUTTER_PLUGIN_EXPORT
#endif

typedef struct _FirebaseCorePlugin FirebaseCorePlugin;
typedef struct {
  GObjectClass parent_class;
} FirebaseCorePluginClass;

FLUTTER_PLUGIN_EXPORT GType firebase_core_plugin_get_type();

FLUTTER_PLUGIN_EXPORT void firebase_core_plugin_register_with_registrar(
    FlPluginRegistrar* registrar);

G_END_DECLS

#ifdef __cplusplus

#include <string>

#include "flutter_firebase_plugin.h"

// Registers a FlutterFirebasePlugin so that its constants are collected during
// Firebase.initializeApp(). The channel_name should match the Dart
// MethodChannel name (e.g. "plugins.flutter.io/firebase_auth").
FLUTTER_PLUGIN_EXPORT void RegisterFlutterFirebasePlugin(
    const std::string& channel_name, FlutterFirebasePlugin* plugin);

#endif  // __cplusplus

#endif  // FLUTTER_PLUGIN_FIREBASE_CORE_PLUGIN_H_
