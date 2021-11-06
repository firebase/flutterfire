// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library firebase_database_web;

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database_platform_interface/firebase_database_platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'src/interop/database.dart' as database_interop;

part './src/database_reference_web.dart';
part './src/ondisconnect_web.dart';
part './src/query_web.dart';
part './src/utils/snapshot_utils.dart';

/// Web implementation for [DatabasePlatform]
/// delegates calls to firebase web plugin
class FirebaseDatabaseWeb extends DatabasePlatform {
  /// Instance of Database from web plugin
  database_interop.Database? _firebaseDatabase;

  /// Lazily initialize [_firebaseDatabase] on first method call
  database_interop.Database get _delegate {
    return _firebaseDatabase ??=
        _firebaseDatabase = database_interop.getDatabaseInstance(
      database_interop.getApp(app?.name),
      databaseURL,
    );
  }

  /// Called by PluginRegistry to register this plugin for Flutter Web
  static void registerWith(Registrar registrar) {
    DatabasePlatform.instance = FirebaseDatabaseWeb();
  }

  /// Builds an instance of [DatabaseWeb] with an optional [FirebaseApp] instance
  /// If [app] is null then the created instance will use the default [FirebaseApp]
  FirebaseDatabaseWeb({FirebaseApp? app, String? databaseURL})
      : super(app: app, databaseURL: databaseURL);

  @override
  DatabasePlatform withApp(FirebaseApp? app, String? databaseURL) =>
      FirebaseDatabaseWeb(app: app, databaseURL: databaseURL);

  @override
  String? appName() => app?.name;

  @override
  DatabaseReferencePlatform reference() {
    return DatabaseReferenceWeb(_delegate, this, <String>[]);
  }

  /// This is not supported on web. However,
  /// If a client loses its network connection, your app will continue functioning correctly.
  ///
  /// The Firebase Realtime Database web APIs do not persist data offline outside of the session.
  /// In order for writes to be persisted to the server,
  /// the web page must not be closed before the data is written to the server.
  ///
  /// On the web, real-time database offline mode work in Tunnel mode not with airplane mode.
  /// check the https://stackoverflow.com/a/32530269/3452078
  @override
  Future<bool> setPersistenceEnabled(bool enabled) async {
    throw UnsupportedError("setPersistenceEnabled() is not supported for web");
  }

  @override
  Future<bool> setPersistenceCacheSizeBytes(int cacheSize) async {
    throw UnsupportedError(
        "setPersistenceCacheSizeBytes() is not supported for web");
  }

  @override
  Future<void> setLoggingEnabled(bool enabled) async {
    database_interop.enableLogging(enabled);
  }

  @override
  Future<void> goOnline() async {
    _delegate.goOnline();
  }

  @override
  Future<void> goOffline() async {
    _delegate.goOffline();
  }

  @override
  Future<void> purgeOutstandingWrites() async {
    throw UnsupportedError("purgeOutstandingWrites() is not supported for web");
  }
}
