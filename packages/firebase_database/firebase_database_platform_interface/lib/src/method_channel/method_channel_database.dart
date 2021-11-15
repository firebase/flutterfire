// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database_platform_interface/firebase_database_platform_interface.dart';
import 'package:flutter/services.dart';

import 'method_channel_database_reference.dart';
import 'utils/exception.dart';

/// The entry point for accessing a FirebaseDatabase.
///
/// You can get an instance by calling [FirebaseDatabase.instance].
class MethodChannelDatabase extends DatabasePlatform {
  MethodChannelDatabase({FirebaseApp? app, String? databaseURL})
      : super(app: app, databaseURL: databaseURL) {
    if (_initialized) return;

    channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'DoTransaction':
          final key = call.arguments['transactionKey'];
          final handler = transactions[key]!;

          final newVal = handler(call.arguments['snapshot']['value']);
          return newVal;
        default:
          throw MissingPluginException(
            '${call.method} method not implemented on the Dart side.',
          );
      }
    });
    _initialized = true;
  }

  static final transactions = <int, TransactionHandler>{};

  static bool _initialized = false;

  /// Gets a [DatabasePlatform] with specific arguments such as a different
  /// [FirebaseApp].
  @override
  DatabasePlatform delegateFor({
    required FirebaseApp app,
    String? databaseURL,
  }) {
    return MethodChannelDatabase(app: app, databaseURL: databaseURL);
  }

  /// The [MethodChannel] used to communicate with the native plugin
  static const MethodChannel channel =
      MethodChannel('plugins.flutter.io/firebase_database');

  /// Returns a [DatabaseReference] representing the location in the Database
  /// corresponding to the provided path.
  /// If no path is provided, the Reference will point to the root of the Database.
  @override
  DatabaseReferencePlatform ref([String? path]) {
    return MethodChannelDatabaseReference(
      database: this,
      pathComponents: path?.split('/').toList() ?? const <String>[],
    );
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
  @override
  Future<void> setPersistenceEnabled(bool enabled) async {
    try {
      await channel.invokeMethod<void>(
        'FirebaseDatabase#setPersistenceEnabled',
        <String, dynamic>{
          'appName': app!.name,
          'databaseURL': databaseURL,
          'enabled': enabled,
        },
      );
    } catch (e, s) {
      throw convertPlatformException(e, s);
    }
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
  @override
  Future<void> setPersistenceCacheSizeBytes(int cacheSize) async {
    try {
      return channel.invokeMethod<void>(
        'FirebaseDatabase#setPersistenceCacheSizeBytes',
        <String, dynamic>{
          'appName': app!.name,
          'databaseURL': databaseURL,
          'cacheSize': cacheSize,
        },
      );
    } catch (e, s) {
      throw convertPlatformException(e, s);
    }
  }

  /// Enables verbose diagnostic logging for debugging your application.
  /// This must be called before any other usage of FirebaseDatabase instance.
  /// By default, diagnostic logging is disabled.
  @override
  Future<void> setLoggingEnabled(bool enabled) async {
    try {
      await channel.invokeMethod<void>(
        'FirebaseDatabase#setLoggingEnabled',
        <String, dynamic>{
          'appName': app!.name,
          'databaseURL': databaseURL,
          'enabled': enabled
        },
      );
    } catch (e, s) {
      throw convertPlatformException(e, s);
    }
  }

  /// Resumes our connection to the Firebase Database backend after a previous
  /// [goOffline] call.
  @override
  Future<void> goOnline() {
    try {
      return channel.invokeMethod<void>(
        'FirebaseDatabase#goOnline',
        <String, dynamic>{
          'appName': app!.name,
          'databaseURL': databaseURL,
        },
      );
    } catch (e, s) {
      throw convertPlatformException(e, s);
    }
  }

  /// Shuts down our connection to the Firebase Database backend until
  /// [goOnline] is called.
  @override
  Future<void> goOffline() {
    try {
      return channel.invokeMethod<void>(
        'FirebaseDatabase#goOffline',
        <String, dynamic>{
          'appName': app!.name,
          'databaseURL': databaseURL,
        },
      );
    } catch (e, s) {
      throw convertPlatformException(e, s);
    }
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
  @override
  Future<void> purgeOutstandingWrites() {
    try {
      return channel.invokeMethod<void>(
        'FirebaseDatabase#purgeOutstandingWrites',
        <String, dynamic>{
          'appName': app!.name,
          'databaseURL': databaseURL,
        },
      );
    } catch (e, s) {
      throw convertPlatformException(e, s);
    }
  }
}
