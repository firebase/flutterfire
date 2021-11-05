// ignore_for_file: require_trailing_commas
// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_database_platform_interface/firebase_database_platform_interface.dart';

import 'method_channel_database.dart';
import 'method_channel_on_disconnect.dart';
import 'method_channel_query.dart';
import 'method_channel_transaction_result.dart';
import 'utils/exception.dart';
import 'utils/push_id_generator.dart';

/// DatabaseReference represents a particular location in your Firebase
/// Database and can be used for reading or writing data to that location.
///
/// This class is the starting point for all Firebase Database operations.
/// After you’ve obtained your first DatabaseReference via
/// `FirebaseDatabase.ref()`, you can use it to read data
/// (ie. `onChildAdded`), write data (ie. `setValue`), and to create new
/// `DatabaseReference`s (ie. `child`).
class MethodChannelDatabaseReference extends MethodChannelQuery
    implements DatabaseReferencePlatform {
  /// Create a [MethodChannelDatabaseReference] from [pathComponents]
  MethodChannelDatabaseReference({
    required DatabasePlatform database,
    required List<String> pathComponents,
  }) : super(
          database: database,
          pathComponents: pathComponents,
          parameters: {},
        );

  @override
  DatabaseReferencePlatform child(String path) {
    return MethodChannelDatabaseReference(
        database: database,
        pathComponents: List<String>.from(pathComponents)
          ..addAll(path.split('/')));
  }

  @override
  DatabaseReferencePlatform? get parent {
    if (pathComponents.isEmpty) {
      return null;
    }

    return MethodChannelDatabaseReference(
      database: database,
      pathComponents: (List<String>.from(pathComponents))..removeLast(),
    );
  }

  @override
  DatabaseReferencePlatform root() {
    return MethodChannelDatabaseReference(
      database: database,
      pathComponents: [],
    );
  }

  @override
  String? get key => pathComponents.isEmpty ? null : pathComponents.last;

  @override
  DatabaseReferencePlatform push() {
    return MethodChannelDatabaseReference(
      database: database,
      pathComponents: List<String>.from(pathComponents)
        ..add(PushIdGenerator.generatePushChildName()),
    );
  }

  @override
  Future<void> set(Object? value) {
    try {
      return MethodChannelDatabase.channel.invokeMethod<void>(
        'DatabaseReference#set',
        <String, dynamic>{
          'appName': database.app!.name,
          'databaseURL': database.databaseURL,
          'path': path,
          'value': value,
        },
      );
    } catch (e, s) {
      throw convertPlatformException(e, s);
    }
  }

  @override
  Future<void> setWithPriority(Object? value, Object? priority) {
    try {
      return MethodChannelDatabase.channel.invokeMethod<void>(
        'DatabaseReference#setWithPriority',
        <String, dynamic>{
          'appName': database.app!.name,
          'databaseURL': database.databaseURL,
          'path': path,
          'value': value,
          'priority': priority,
        },
      );
    } catch (e, s) {
      throw convertPlatformException(e, s);
    }
  }

  @override
  Future<void> update(Map<String, Object?> value) {
    try {
      return MethodChannelDatabase.channel.invokeMethod<void>(
        'DatabaseReference#update',
        <String, dynamic>{
          'appName': database.app!.name,
          'databaseURL': database.databaseURL,
          'path': path,
          'value': value,
        },
      );
    } catch (e, s) {
      throw convertPlatformException(e, s);
    }
  }

  @override
  Future<void> setPriority(Object? priority) async {
    try {
      return MethodChannelDatabase.channel.invokeMethod<void>(
        'DatabaseReference#setPriority',
        <String, dynamic>{
          'appName': database.app!.name,
          'databaseURL': database.databaseURL,
          'path': path,
          'priority': priority,
        },
      );
    } catch (e, s) {
      throw convertPlatformException(e, s);
    }
  }

  @override
  Future<void> remove() => set(null);

  @override
  Future<TransactionResultPlatform> runTransaction(
    TransactionHandler transactionHandler, {
    bool applyLocally = true,
  }) async {
    const channel = MethodChannelDatabase.channel;
    final handlers = MethodChannelDatabase.transactions;
    final key = handlers.isEmpty ? 0 : handlers.keys.last + 1;

    MethodChannelDatabase.transactions[key] = transactionHandler;

    // TODO Handle Abort transactions somehow?
    try {
      final result = await channel.invokeMethod(
        'DatabaseReference#runTransaction',
        <String, dynamic>{
          'appName': database.app!.name,
          'databaseURL': database.databaseURL,
          'path': path,
          'transactionApplyLocally': applyLocally,
          'transactionKey': key,
        },
      );

      return MethodChannelTransactionResult(
          result!['committed'] as bool, this, result!['snapshot']);
    } catch (e, s) {
      throw convertPlatformException(e, s);
    } finally {
      handlers.remove(key);
    }
  }

  @override
  OnDisconnectPlatform onDisconnect() {
    return MethodChannelOnDisconnect(
      database: database,
      ref: this,
    );
  }
}
