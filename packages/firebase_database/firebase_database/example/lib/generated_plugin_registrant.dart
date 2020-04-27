//
// Generated file. Do not edit.
//

// ignore: unused_import
import 'dart:ui';

import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:firebase_database_web/firebase_database_web.dart';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';

// ignore: public_member_api_docs
void registerPlugins(PluginRegistry registry) {
  FirebaseCoreWeb.registerWith(registry.registrarFor(FirebaseCoreWeb));
  DatabaseWeb.registerWith(registry.registrarFor(DatabaseWeb));
  registry.registerMessageHandler();
}
