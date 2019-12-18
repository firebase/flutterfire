//
// Generated file. Do not edit.
//
import 'dart:ui';

import 'package:cloud_firestore_web/firestore_web.dart';
import 'package:firebase_core_web/firebase_core_web.dart';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void registerPlugins(PluginRegistry registry) {
  FirestoreWeb.registerWith(registry.registrarFor(FirestoreWeb));
  FirebaseCoreWeb.registerWith(registry.registrarFor(FirebaseCoreWeb));
  registry.registerMessageHandler();
}
