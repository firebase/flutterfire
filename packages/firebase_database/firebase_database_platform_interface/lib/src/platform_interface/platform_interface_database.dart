// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database_platform_interface/firebase_database_platform_interface.dart';
import 'package:meta/meta.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../method_channel/method_channel_database.dart';

/// Defines an interface to work with [FirebaseDatabase] on web and mobile
abstract class DatabasePlatform extends PlatformInterface {
  /// The [FirebaseApp] instance to which this [FirebaseDatabase] belongs.
  ///
  /// If null, the default [FirebaseApp] is used.
  final FirebaseApp? app;

  /// Gets an instance of [FirebaseDatabase].
  ///
  /// If [app] is specified, its options should include a [databaseURL].

  DatabasePlatform({this.app, this.databaseURL}) : super(token: _token);

  static final Object _token = Object();

  /// Create an instance using [app] using the existing implementation
  factory DatabasePlatform.instanceFor({
    required FirebaseApp app,
    String? databaseURL,
  }) {
    return DatabasePlatform.instance
        .delegateFor(app: app, databaseURL: databaseURL);
  }

  /// The current default [DatabasePlatform] instance.
  ///
  /// It will always default to [MethodChannelDatabase]
  /// if no web implementation was provided.
  static DatabasePlatform? _instance;

  /// The current default [DatabasePlatform] instance.
  ///
  /// It will always default to [MethodChannelDatabase]
  /// if no other implementation was provided.
  static DatabasePlatform get instance {
    return _instance ??= MethodChannelDatabase();
  }

  static set instance(DatabasePlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  /// Enables delegates to create new instances of themselves if a none default
  /// [FirebaseApp] instance is required by the user.
  @protected
  DatabasePlatform delegateFor({
    required FirebaseApp app,
    String? databaseURL,
  }) {
    throw UnimplementedError('delegateFor() is not implemented');
  }

  /// The URL to which this [FirebaseDatabase] belongs
  ///
  /// If null, the URL of the specified [FirebaseApp] is used
  final String? databaseURL;

  /// Returns any arguments to be provided to a [MethodChannel].
  Map<String, Object?> getChannelArguments([Map<String, Object?>? other]) {
    throw UnimplementedError('getChannelArguments() is not implemented');
  }

  /// Changes this instance to point to a FirebaseDatabase emulator running locally.
  ///
  /// Set the [host] of the local emulator, such as "localhost"
  /// Set the [port] of the local emulator, such as "9000" (default is 9000)
  ///
  /// Note: Must be called immediately, prior to accessing FirebaseFirestore methods.
  /// Do not use with production credentials as emulator traffic is not encrypted.
  void useDatabaseEmulator(String host, int port) {
    throw UnimplementedError('useDatabaseEmulator() not implemented');
  }

  /// Gets a DatabaseReference for the root of your Firebase Database.
  DatabaseReferencePlatform ref([String? path]) {
    throw UnimplementedError('ref() not implemented');
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
  void setPersistenceEnabled(bool enabled) {
    throw UnimplementedError('setPersistenceEnabled() not implemented');
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
  /// the value could not be set (because database references have already been
  /// created).
  ///
  /// Note that the specified cache size is only an approximation and the size
  /// on disk may temporarily exceed it at times. Cache sizes smaller than 1 MB
  /// or greater than 100 MB are not supported.
  void setPersistenceCacheSizeBytes(int cacheSize) {
    throw UnimplementedError('setPersistenceCacheSizeBytes() not implemented');
  }

  /// Enables verbose diagnostic logging for debugging your application.
  /// This must be called before any other usage of FirebaseDatabase instance.
  /// By default, diagnostic logging is disabled.
  void setLoggingEnabled(bool enabled) {
    throw UnimplementedError('setLoggingEnabled() not implemented');
  }

  /// Resumes our connection to the Firebase Database backend after a previous
  /// [goOffline] call.
  Future<void> goOnline() {
    throw UnimplementedError('goOnline() not implemented');
  }

  /// Shuts down our connection to the Firebase Database backend until
  /// [goOnline] is called.
  Future<void> goOffline() {
    throw UnimplementedError('goOffline() not implemented');
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
    throw UnimplementedError('purgeOutstandingWrites() not implemented');
  }
}
