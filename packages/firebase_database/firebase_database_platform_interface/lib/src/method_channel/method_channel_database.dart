// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database_platform_interface/firebase_database_platform_interface.dart';
import 'package:firebase_database_platform_interface/src/method_channel/utils/utils.dart';
import 'package:flutter/services.dart';

import 'method_channel_database_reference.dart';
import 'utils/exception.dart';

class MethodChannelArguments {
  MethodChannelArguments(this.app);

  FirebaseApp app;
}

/// The entry point for accessing a FirebaseDatabase.
///
/// You can get an instance by calling [FirebaseDatabase.instance].
class MethodChannelDatabase extends DatabasePlatform {
  MethodChannelDatabase({FirebaseApp? app, String? databaseURL})
      : super(app: app, databaseURL: databaseURL) {
    if (_initialized) return;

    channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'FirebaseDatabase#callTransactionHandler':
          Object? value;
          bool aborted = false;
          bool exception = false;
          final key = call.arguments['transactionKey'];

          try {
            final handler = transactions[key];
            if (handler == null) {
              // This shouldn't happen but on the off chance that it does, e.g.
              // as a side effect of Hot Reloading/Restarting, then we should
              // just abort the transaction.
              aborted = true;
            } else {
              Transaction transaction =
                  handler(call.arguments['snapshot']['value']);
              aborted = transaction.aborted;
              value = transaction.value;
            }
          } catch (e) {
            exception = true;
            // We store thrown errors so we can rethrow when the runTransaction
            // Future completes from native code - to avoid serializing the error
            // and sending it to native only to have to send it back again.
            transactionErrors[key] = e;
          }

          return {
            if (value != null) 'value': transformValue(value),
            'aborted': aborted,
            'exception': exception,
          };
        default:
          throw MissingPluginException(
            '${call.method} method not implemented on the Dart side.',
          );
      }
    });
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
  static const MethodChannel channel =
      MethodChannel('plugins.flutter.io/firebase_database');

  @override
  void useDatabaseEmulator(String host, int port) {
    _emulatorHost = host;
    _emulatorPort = port;
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
  }

  @override
  void setPersistenceCacheSizeBytes(int cacheSize) {
    _cacheSizeBytes = cacheSize;
  }

  @override
  void setLoggingEnabled(bool enabled) {
    _loggingEnabled = enabled;
  }

  @override
  Future<void> goOnline() {
    try {
      return channel.invokeMethod<void>(
        'FirebaseDatabase#goOnline',
        getChannelArguments(),
      );
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  /// Shuts down our connection to the Firebase Database backend until
  /// [goOnline] is called.
  @override
  Future<void> goOffline() {
    try {
      return channel.invokeMethod<void>(
        'FirebaseDatabase#goOffline',
        getChannelArguments(),
      );
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
      return channel.invokeMethod<void>(
        'FirebaseDatabase#purgeOutstandingWrites',
        getChannelArguments(),
      );
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }
}
