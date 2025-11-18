// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_database_platform_interface/firebase_database_platform_interface.dart';
import 'package:firebase_database_platform_interface/src/method_channel/utils/utils.dart';
import 'package:firebase_database_platform_interface/src/pigeon/messages.pigeon.dart'
    hide DatabaseReferencePlatform;

import 'method_channel_database.dart';
import 'method_channel_on_disconnect.dart';
import 'method_channel_query.dart';
import 'method_channel_transaction_result.dart';
import 'utils/exception.dart';
import 'utils/push_id_generator.dart';

final _api = FirebaseDatabaseHostApi();

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

  /// Gets the Pigeon app object from the database
  DatabasePigeonFirebaseApp get _pigeonApp {
    final methodChannelDatabase = database as MethodChannelDatabase;
    return methodChannelDatabase.pigeonApp;
  }

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
      await _api.databaseReferenceSet(
        _pigeonApp,
        DatabaseReferenceRequest(
          path: path,
          value: value != null ? transformValue(value) : null,
        ),
      );
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<void> setWithPriority(Object? value, Object? priority) async {
    try {
      await _api.databaseReferenceSetWithPriority(
        _pigeonApp,
        DatabaseReferenceRequest(
          path: path,
          value: value != null ? transformValue(value) : null,
          priority: priority,
        ),
      );
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<void> update(Map<String, Object?> value) async {
    try {
      await _api.databaseReferenceUpdate(
        _pigeonApp,
        UpdateRequest(
          path: path,
          value: transformValue(value)! as Map<String, Object?>,
        ),
      );
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<void> setPriority(Object? priority) async {
    try {
      await _api.databaseReferenceSetPriority(
        _pigeonApp,
        DatabaseReferenceRequest(
          path: path,
          priority: priority,
        ),
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
    final handlers = MethodChannelDatabase.transactions;
    final handlerErrors = MethodChannelDatabase.transactionErrors;
    final key = handlers.isEmpty ? 0 : handlers.keys.last + 1;

    // Store the handler to be called at a later time by native method channels.
    MethodChannelDatabase.transactions[key] = transactionHandler;

    try {
      await _api.databaseReferenceRunTransaction(
        _pigeonApp,
        TransactionRequest(
          path: path,
          transactionKey: key,
          applyLocally: applyLocally,
        ),
      );

      // Get the transaction result using Pigeon
      final result = await _api.databaseReferenceGetTransactionResult(
        _pigeonApp,
        key,
      );

      // We store Dart only errors that occur inside users handlers - to avoid
      // serializing the error and sending it to native only to have to send it
      // back again. If we stored one, throw it now.
      final possibleError = handlerErrors[key];
      if (possibleError != null) {
        throw possibleError;
      }

      return MethodChannelTransactionResult(
        result['committed']! as bool,
        this,
        Map<String, dynamic>.from(result['snapshot']! as Map),
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
