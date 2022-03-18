// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_database_platform_interface/firebase_database_platform_interface.dart';
import 'package:firebase_database_platform_interface/src/method_channel/utils/utils.dart';

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
        );

  @override
  DatabaseReferencePlatform child(String path) {
    return MethodChannelDatabaseReference(
      database: database,
      pathComponents: List<String>.from(pathComponents)
        ..addAll(path.split('/')),
    );
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
  Future<void> set(Object? value) async {
    try {
      await MethodChannelDatabase.channel.invokeMethod<void>(
        'DatabaseReference#set',
        database.getChannelArguments({
          'path': path,
          if (value != null) 'value': transformValue(value),
        }),
      );
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<void> setWithPriority(Object? value, Object? priority) async {
    try {
      await MethodChannelDatabase.channel.invokeMethod<void>(
        'DatabaseReference#setWithPriority',
        database.getChannelArguments({
          'path': path,
          if (value != null) 'value': transformValue(value),
          if (priority != null) 'priority': priority,
        }),
      );
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<void> update(Map<String, Object?> value) async {
    try {
      await MethodChannelDatabase.channel.invokeMethod<void>(
        'DatabaseReference#update',
        database.getChannelArguments({
          'path': path,
          'value': transformValue(value),
        }),
      );
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<void> setPriority(Object? priority) async {
    try {
      await MethodChannelDatabase.channel.invokeMethod<void>(
        'DatabaseReference#setPriority',
        database.getChannelArguments({
          'path': path,
          if (priority != null) 'priority': priority,
        }),
      );
    } catch (e, s) {
      convertPlatformException(e, s);
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
    final handlerErrors = MethodChannelDatabase.transactionErrors;
    final key = handlers.isEmpty ? 0 : handlers.keys.last + 1;

    // Store the handler to be called at a later time by native method channels.
    MethodChannelDatabase.transactions[key] = transactionHandler;

    try {
      final result = await channel.invokeMethod(
        'DatabaseReference#runTransaction',
        database.getChannelArguments({
          'path': path,
          'transactionApplyLocally': applyLocally,
          'transactionKey': key,
        }),
      );

      // We store Dart only errors that occur inside users handlers - to avoid
      // serializing the error and sending it to native only to have to send it
      // back again. If we stored one, throw it now.
      final possibleError = handlerErrors[key];
      if (possibleError != null) {
        throw possibleError;
      }

      return MethodChannelTransactionResult(
        result!['committed'] as bool,
        this,
        Map.from(result!['snapshot']),
      );
    } catch (e, s) {
      convertPlatformException(e, s);
    } finally {
      handlers.remove(key);
      handlerErrors.remove(key);
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
