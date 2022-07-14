// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library firebase_database_web;

import 'dart:async';
import 'dart:js_util' as util;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:firebase_database_platform_interface/firebase_database_platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:firebase_core_web/firebase_core_web_interop.dart'
    as core_interop;
import 'src/interop/database.dart' as database_interop;

part './src/data_snapshot_web.dart';

part './src/database_event_web.dart';

part './src/database_reference_web.dart';

part './src/ondisconnect_web.dart';

part './src/query_web.dart';

part './src/transaction_result_web.dart';

part './src/utils/exception.dart';

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
      core_interop.app(app?.name),
      databaseURL,
    );
  }

  /// Called by PluginRegistry to register this plugin for Flutter Web
  static void registerWith(Registrar registrar) {
    FirebaseCoreWeb.registerService('database');
    DatabasePlatform.instance = FirebaseDatabaseWeb();
  }

  /// Builds an instance of [DatabaseWeb] with an optional [FirebaseApp] instance
  /// If [app] is null then the created instance will use the default [FirebaseApp]
  FirebaseDatabaseWeb({FirebaseApp? app, String? databaseURL})
      : super(app: app, databaseURL: databaseURL);

  @override
  DatabasePlatform delegateFor(
      {required FirebaseApp app, String? databaseURL}) {
    return FirebaseDatabaseWeb(app: app, databaseURL: databaseURL);
  }

  @override
  DatabaseReferencePlatform ref([String? path]) {
    return DatabaseReferenceWeb(this, _delegate.ref(path));
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
  void setPersistenceEnabled(bool enabled) {
    throw UnsupportedError("setPersistenceEnabled() is not supported for web");
  }

  @override
  void setPersistenceCacheSizeBytes(int cacheSize) {
    throw UnsupportedError(
        "setPersistenceCacheSizeBytes() is not supported for web");
  }

  @override
  void setLoggingEnabled(bool enabled) {
    database_interop.enableLogging(enabled);
  }

  @override
  Future<void> goOnline() async {
    try {
      _delegate.goOnline();
    } catch (e, s) {
      throw convertFirebaseDatabaseException(e, s);
    }
  }

  @override
  Future<void> goOffline() async {
    try {
      _delegate.goOffline();
    } catch (e, s) {
      throw convertFirebaseDatabaseException(e, s);
    }
  }

  @override
  Future<void> purgeOutstandingWrites() async {
    throw UnsupportedError("purgeOutstandingWrites() is not supported for web");
  }

  @override
  void useDatabaseEmulator(String host, int port) {
    try {
      _delegate.useDatabaseEmulator(host, port);
    } catch (e) {
      FirebaseException exception = convertFirebaseDatabaseException(e);

      // Hot reload keeps state, so ignore if this is thrown.
      if (exception.message != null &&
          exception.message!.contains(
              'Cannot call useEmulator() after instance has already been initialized')) {
        return;
      }

      throw exception;
    }
  }
}
