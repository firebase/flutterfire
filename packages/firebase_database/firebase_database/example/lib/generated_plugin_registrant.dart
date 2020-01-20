//
// Generated file. Do not edit.
//
import 'dart:ui';

import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:firebase_database_web/firebase_database_web.dart';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void registerPlugins(PluginRegistry registry) {
  FirebaseCoreWeb.registerWith(registry.registrarFor(FirebaseCoreWeb));
  DatabaseWeb.registerWith(registry.registrarFor(DatabaseWeb));
  registry.registerMessageHandler();
}
