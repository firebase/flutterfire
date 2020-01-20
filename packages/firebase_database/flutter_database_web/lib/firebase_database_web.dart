library firebase_database_web;

import 'dart:async';

import "package:firebase/firebase.dart" as firebase;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database_platform_interface/firebase_database_platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:meta/meta.dart';

part './database_reference_web.dart';
part './query_web.dart';
part './ondisconnect_web.dart';
part './datasnapshot_web.dart';

class DatabaseWeb extends DatabasePlatform {
  /// Instance of Database from web plugin
  firebase.Database webDatabase;

  static void registerWith(Registrar registrar) {
    DatabasePlatform.instance = DatabaseWeb();
  }

  DatabaseWeb({FirebaseApp app, String databaseUrl})
      : webDatabase =
            firebase.database(firebase.app((app ?? FirebaseApp.instance).name)),
        super(app: app ?? FirebaseApp.instance, databaseURL: databaseUrl);

  @override
  DatabasePlatform withApp(FirebaseApp app) => DatabaseWeb(app: app);

  @override
  String appName() => app.name;
  @override
  Future<bool> setPersistenceEnabled(bool enabled) {
    throw UnsupportedError("setPersistenceEnabled() is not supported for web");
  }

  @override
  Future<bool> setPersistenceCacheSizeBytes(int cacheSize) {
    throw UnsupportedError(
        "setPersistenceCacheSizeBytes() is not supported for web");
  }

  @override
  Future<void> goOffline() {
    webDatabase.goOffline();
  }

  @override
  Future<void> goOnline() {
    webDatabase.goOnline();
  }

  @override
  DatabaseReference reference() {
    return DatabaseReferenceWeb(webDatabase, this, <String>[]);
  }

  @override
  Future<void> purgeOutstandingWrites() {
    throw UnsupportedError("purgeOutstandingWrites() is not supported for web");
  }
}
