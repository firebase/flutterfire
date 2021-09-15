// ignore_for_file: require_trailing_commas
// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_database_platform_interface;

/// The entry point for accessing a FirebaseDatabase.
///
/// You can get an instance by calling [FirebaseDatabase.instance].
class MethodChannelDatabase extends DatabasePlatform {
  /// Gets an instance of [FirebaseDatabase].
  ///
  /// If [app] is specified, its options should include a [databaseURL].
  MethodChannelDatabase({FirebaseApp? app, String? databaseURL})
      : super(app: app, databaseURL: databaseURL) {
    if (_initialized) return;
    channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'Event':
          EventPlatform event = EventPlatform(call.arguments);
          _observers[call.arguments['handle']]?.add(event);
          return null;
        case 'Error':
          final DatabaseErrorPlatform error =
              DatabaseErrorPlatform(call.arguments['error']);
          _observers[call.arguments['handle']]?.addError(error);
          return null;
        case 'DoTransaction':
          final MutableData mutableData =
              MutableData.private(call.arguments['snapshot']);
          final MutableData updated =
              _transactions[call.arguments['transactionKey']]!(mutableData);
          return <String, dynamic>{'value': updated.value};
        default:
          throw MissingPluginException(
            '${call.method} method not implemented on the Dart side.',
          );
      }
    });
    _initialized = true;
  }

  @override
  DatabasePlatform withApp(FirebaseApp? app, String? databaseURL) =>
      MethodChannelDatabase(
        app: app,
        databaseURL: databaseURL,
      );

  @override
  String? appName() => app?.name;

  static final Map<int, StreamController<EventPlatform>> _observers =
      <int, StreamController<EventPlatform>>{};

  static final Map<int, TransactionHandler> _transactions =
      <int, TransactionHandler>{};

  static bool _initialized = false;

  /// The [MethodChannel] used to communicate with the native plugin
  static const MethodChannel channel =
      MethodChannel('plugins.flutter.io/firebase_database');

  /// Returns a [DatabaseReference] representing the location in the Database
  /// corresponding to the provided path.
  /// If no path is provided, the Reference will point to the root of the Database.
  @override
  DatabaseReferencePlatform ref([String? path = '']) {
    return MethodChannelDatabaseReference(
      database: this,
      pathComponents: path!.split('/').toList(),
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
  Future<bool> setPersistenceEnabled(bool enabled) async {
    final bool? result = await channel.invokeMethod<bool>(
      'FirebaseDatabase#setPersistenceEnabled',
      <String, dynamic>{
        'app': app?.name,
        'databaseURL': databaseURL,
        'enabled': enabled,
      },
    );
    return result!;
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
  Future<bool> setPersistenceCacheSizeBytes(int cacheSize) async {
    final bool? result = await channel.invokeMethod<bool>(
      'FirebaseDatabase#setPersistenceCacheSizeBytes',
      <String, dynamic>{
        'app': app?.name,
        'databaseURL': databaseURL,
        'cacheSize': cacheSize,
      },
    );
    return result!;
  }

  /// Enables verbose diagnostic logging for debugging your application.
  /// This must be called before any other usage of FirebaseDatabase instance.
  /// By default, diagnostic logging is disabled.
  @override
  Future<void> setLoggingEnabled(bool enabled) {
    return channel.invokeMethod<void>(
      'FirebaseDatabase#setLoggingEnabled',
      <String, dynamic>{
        'app': app?.name,
        'databaseURL': databaseURL,
        'enabled': enabled
      },
    );
  }

  /// Resumes our connection to the Firebase Database backend after a previous
  /// [goOffline] call.
  @override
  Future<void> goOnline() {
    return channel.invokeMethod<void>(
      'FirebaseDatabase#goOnline',
      <String, dynamic>{
        'app': app?.name,
        'databaseURL': databaseURL,
      },
    );
  }

  /// Shuts down our connection to the Firebase Database backend until
  /// [goOnline] is called.
  @override
  Future<void> goOffline() {
    return channel.invokeMethod<void>(
      'FirebaseDatabase#goOffline',
      <String, dynamic>{
        'app': app?.name,
        'databaseURL': databaseURL,
      },
    );
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
    return channel.invokeMethod<void>(
      'FirebaseDatabase#purgeOutstandingWrites',
      <String, dynamic>{
        'app': app?.name,
        'databaseURL': databaseURL,
      },
    );
  }
}
