// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database_platform_interface/firebase_database_platform_interface.dart';
import 'package:firebase_database_platform_interface/src/method_channel/utils/utils.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database_platform_interface/src/pigeon/messages.pigeon.dart'
    hide DatabaseReferencePlatform;

import 'method_channel_database_reference.dart';
import 'utils/exception.dart';

class MethodChannelArguments {
  MethodChannelArguments(this.app);

  FirebaseApp app;
}

class _TransactionHandlerFlutterApi extends FirebaseDatabaseFlutterApi {
  @override
  Future<TransactionHandlerResult> callTransactionHandler(
    int transactionKey,
    Object? snapshotValue,
  ) async {
    Object? value;
    bool aborted = false;
    bool exception = false;

    try {
      final handler = MethodChannelDatabase.transactions[transactionKey];
      if (handler == null) {
        // This shouldn't happen but on the off chance that it does, e.g.
        // as a side effect of Hot Reloading/Restarting, then we should
        // just abort the transaction.
        aborted = true;
      } else {
        Transaction transaction = handler(snapshotValue);
        aborted = transaction.aborted;
        value = transaction.value;
      }
    } catch (e) {
      exception = true;
      // We store thrown errors so we can rethrow when the runTransaction
      // Future completes from native code - to avoid serializing the error
      // and sending it to native only to have to send it back again.
      MethodChannelDatabase.transactionErrors[transactionKey] = e;
    }

    return TransactionHandlerResult(
      value: value != null ? transformValue(value) : null,
      aborted: aborted,
      exception: exception,
    );
  }
}

/// The entry point for accessing a FirebaseDatabase.
///
/// You can get an instance by calling [FirebaseDatabase.instance].
class MethodChannelDatabase extends DatabasePlatform {
  static final _api = FirebaseDatabaseHostApi();

  /// Creates a DatabasePigeonFirebaseApp object with current settings
  DatabasePigeonFirebaseApp get pigeonApp {
    return DatabasePigeonFirebaseApp(
      appName: app!.name,
      databaseURL: databaseURL,
      settings: DatabasePigeonSettings(
        persistenceEnabled: _persistenceEnabled,
        cacheSizeBytes: _cacheSizeBytes,
        loggingEnabled: _loggingEnabled,
        emulatorHost: _emulatorHost,
        emulatorPort: _emulatorPort,
      ),
    );
  }

  MethodChannelDatabase({FirebaseApp? app, String? databaseURL})
      : super(app: app, databaseURL: databaseURL) {
    if (_initialized) return;

    // Set up the Pigeon FlutterApi for transaction handler callbacks
    FirebaseDatabaseFlutterApi.setUp(_TransactionHandlerFlutterApi());
    _initialized = true;
  }

  static final transactions = <int, TransactionHandler>{};
  static final transactionErrors = <int, Object?>{};

  static bool _initialized = false;

  bool? _persistenceEnabled;
  int? _cacheSizeBytes;
  bool? _loggingEnabled;
  String? _emulatorHost;
  int? _emulatorPort;

  @override
  Map<String, Object?> getChannelArguments([Map<String, Object?>? other]) {
    return {
      'appName': app!.name,
      if (databaseURL != null) 'databaseURL': databaseURL,
      if (_persistenceEnabled != null)
        'persistenceEnabled': _persistenceEnabled,
      if (_cacheSizeBytes != null) 'cacheSizeBytes': _cacheSizeBytes,
      if (_loggingEnabled != null) 'loggingEnabled': _loggingEnabled,
      if (_emulatorHost != null) 'emulatorHost': _emulatorHost,
      if (_emulatorPort != null) 'emulatorPort': _emulatorPort,
    }..addAll(other ?? {});
  }

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
  /// This is kept for backward compatibility with query operations
  static const MethodChannel channel =
      MethodChannel('plugins.flutter.io/firebase_database');

  @override
  void useDatabaseEmulator(String host, int port) {
    _emulatorHost = host;
    _emulatorPort = port;
    // Call the Pigeon method to set up the emulator
    _api.useDatabaseEmulator(pigeonApp, host, port);
  }

  @override
  DatabaseReferencePlatform ref([String? path]) {
    return MethodChannelDatabaseReference(
      database: this,
      pathComponents: path?.split('/').toList() ?? const <String>[],
    );
  }

  @override
  void setPersistenceEnabled(bool enabled) {
    _persistenceEnabled = enabled;
    // Call the Pigeon method to set persistence
    _api.setPersistenceEnabled(pigeonApp, enabled);
  }

  @override
  void setPersistenceCacheSizeBytes(int cacheSize) {
    _cacheSizeBytes = cacheSize;
    // Call the Pigeon method to set cache size
    _api.setPersistenceCacheSizeBytes(pigeonApp, cacheSize);
  }

  @override
  void setLoggingEnabled(bool enabled) {
    _loggingEnabled = enabled;
    // Call the Pigeon method to set logging
    _api.setLoggingEnabled(pigeonApp, enabled);
  }

  @override
  Future<void> goOnline() {
    try {
      return _api.goOnline(pigeonApp);
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  /// Shuts down our connection to the Firebase Database backend until
  /// [goOnline] is called.
  @override
  Future<void> goOffline() {
    try {
      return _api.goOffline(pigeonApp);
    } catch (e, s) {
      convertPlatformException(e, s);
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
      return _api.purgeOutstandingWrites(pigeonApp);
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }
}
