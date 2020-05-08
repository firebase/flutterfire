// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library firebase_database_platform_interface;

import 'dart:async';
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

part 'src/platform_interface/database_reference.dart';
part 'src/method_channel/method_channel_database.dart';
part 'src/method_channel/method_channel_database_reference.dart';
part 'src/method_channel/method_channel_on_disconnect.dart';
part 'src/platform_interface/query.dart';
part 'src/platform_interface/on_disconnect.dart';
part 'src/platform_interface/event.dart';
part 'src/method_channel/method_channel_query.dart';
part 'src/method_channel/utils/push_id_generator.dart';
part 'src/method_channel/utils/event_utils.dart';

/// Defines an interface to work with [FirebaseDatabase] on web and mobile
abstract class DatabasePlatform extends PlatformInterface {
  /// The [FirebaseApp] instance to which this [FirebaseDatabase] belongs.
  ///
  /// If null, the default [FirebaseApp] is used.
  final FirebaseApp app;

  /// Gets an instance of [FirebaseDatabase].
  ///
  /// If [app] is specified, its options should include a [databaseURL].

  DatabasePlatform({FirebaseApp app, this.databaseURL})
      : app = app ?? FirebaseApp.instance,
        super(token: _token);

  static final Object _token = Object();

  /// Create an instance using [app] using the existing implementation
  factory DatabasePlatform.instanceFor({FirebaseApp app}) {
    return DatabasePlatform.instance.withApp(app);
  }

  /// The current default [DatabasePlatform] instance.
  ///
  /// It will always default to [MethodChannelDatabase]
  /// if no web implementation was provided.
  static DatabasePlatform get instance {
    if (_instance == null) {
      _instance = MethodChannelDatabase();
    }
    return _instance;
  }

  static DatabasePlatform _instance;
  static set instance(DatabasePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Create a new [DatabasePlatform] with a [FirebaseApp] instance
  DatabasePlatform withApp(FirebaseApp app) {
    throw UnimplementedError("withApp() not implemented");
  }

  ///
  String appName() {
    throw UnimplementedError("appName() not implemented");
  }

  /// The URL to which this [FirebaseDatabase] belongs
  ///
  /// If null, the URL of the specified [FirebaseApp] is used
  final String databaseURL;

  /// Gets a DatabaseReference for the root of your Firebase Database.
  DatabaseReferencePlatform reference() {
    throw UnimplementedError("reference() not implemented");
  }

  /// Attempts to sets the database persistence to [enabled].
  ///
  /// This property must be set before calling methods on database references
  /// and only needs to be called once per application. The returned [Future]
  /// will complete with `true` if the operation was successful or `false` if
  /// the persistence could not be set (because database references have
  /// already been created).
  ///
  /// The Firebase Database client will cache synchronized data and keep track
  /// of all writes you’ve initiated while your application is running. It
  /// seamlessly handles intermittent network connections and re-sends write
  /// operations when the network connection is restored.
  ///
  /// However by default your write operations and cached data are only stored
  /// in-memory and will be lost when your app restarts. By setting [enabled]
  /// to `true`, the data will be persisted to on-device (disk) storage and will
  /// thus be available again when the app is restarted (even when there is no
  /// network connectivity at that time).
  Future<bool> setPersistenceEnabled(bool enabled) async {
    throw UnimplementedError("setPersistenceEnabled() not implemented");
  }

  /// Attempts to set the size of the persistence cache.
  ///
  /// By default the Firebase Database client will use up to 10MB of disk space
  /// to cache data. If the cache grows beyond this size, the client will start
  /// removing data that hasn’t been recently used. If you find that your
  /// application caches too little or too much data, call this method to change
  /// the cache size.
  ///
  /// This property must be set before calling methods on database references
  /// and only needs to be called once per application. The returned [Future]
  /// will complete with `true` if the operation was successful or `false` if
  /// the value could not be set (because database references have already been
  /// created).
  ///
  /// Note that the specified cache size is only an approximation and the size
  /// on disk may temporarily exceed it at times. Cache sizes smaller than 1 MB
  /// or greater than 100 MB are not supported.
  Future<bool> setPersistenceCacheSizeBytes(double cacheSize) async {
    throw UnimplementedError("setPersistenceCacheSizeBytes() not implemented");
  }

  /// Resumes our connection to the Firebase Database backend after a previous
  /// [goOffline] call.
  Future<void> goOnline() {
    throw UnimplementedError("goOnline() not implemented");
  }

  /// Shuts down our connection to the Firebase Database backend until
  /// [goOnline] is called.
  Future<void> goOffline() {
    throw UnimplementedError("goOffline() not implemented");
  }

  /// The Firebase Database client automatically queues writes and sends them to
  /// the server at the earliest opportunity, depending on network connectivity.
  /// In some cases (e.g. offline usage) there may be a large number of writes
  /// waiting to be sent. Calling this method will purge all outstanding writes
  /// so they are abandoned.
  ///
  /// All writes will be purged, including transactions and onDisconnect writes.
  /// The writes will be rolled back locally, perhaps triggering events for
  /// affected event listeners, and the client will not (re-)send them to the
  /// Firebase Database backend.
  Future<void> purgeOutstandingWrites() {
    throw UnimplementedError("purgeOutstandingWrites() not implemented");
  }
}
