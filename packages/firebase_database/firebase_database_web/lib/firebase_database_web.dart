library firebase_database_web;

import 'dart:async';

import "package:firebase/firebase.dart" as web;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database_platform_interface/firebase_database_platform_interface.dart';
import 'package:firebase_database_web/src/utils/event_utils.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

part './src/database_reference_web.dart';
part './src/query_web.dart';
part './src/ondisconnect_web.dart';

/// Web implementation for [DatabasePlatform]
/// delegates calls to firebase web plugin
class DatabaseWeb extends DatabasePlatform {
  /// Instance of Database from web plugin
  web.Database webDatabase;

  /// Called by PluginRegistry to register this plugin for Flutter Web
  static void registerWith(Registrar registrar) {
    DatabasePlatform.instance = DatabaseWeb();
  }

  /// Builds an instance of [DatabaseWeb] with an optional [FirebaseApp] instance
  /// If [app] is null then the created instance will use the default [FirebaseApp]
  DatabaseWeb({FirebaseApp app, String databaseUrl})
      : webDatabase = web.database(web.app((app ?? FirebaseApp.instance).name)),
        super(app: app ?? FirebaseApp.instance, databaseURL: databaseUrl);

  @override
  DatabasePlatform withApp(FirebaseApp app) => DatabaseWeb(app: app);

  @override
  String appName() => app.name;

  @override
  Future<bool> setPersistenceEnabled(bool enabled) async {
    throw Exception("setPersistenceEnabled() is not supported for web");
  }

  @override
  Future<bool> setPersistenceCacheSizeBytes(double cacheSize) async {
    throw Exception("setPersistenceCacheSizeBytes() is not supported for web");
  }

  @override
  Future<void> goOffline() async {
    webDatabase.goOffline();
  }

  @override
  Future<void> goOnline() async {
    webDatabase.goOnline();
  }

  @override
  DatabaseReference reference() {
    return DatabaseReferenceWeb(webDatabase, this, <String>[]);
  }

  @override
  Future<void> purgeOutstandingWrites() async {
    print("purgeOutstandingWrites() is not supported for web");
  }
}
