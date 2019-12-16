library cloud_firestore_platform_interface;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart' show required, visibleForTesting;

part 'src/method_channel_firestore.dart';

part 'src/blob.dart';

part 'src/utils/auto_id_generator.dart';

part 'src/platform_interface/collection_reference.dart';
part 'src/method_channel_collection_reference.dart';

part 'src/document_change.dart';

part 'src/method_channel_document_reference.dart';

part 'src/platform_interface/document_reference_interface.dart';

part 'src/document_snapshot.dart';

part 'src/field_path.dart';

part 'src/field_value.dart';

part 'src/firestore_message_codec.dart';

part 'src/geo_point.dart';

part 'src/method_channel_query.dart';

part 'src/platform_interface/query.dart';

part 'src/platform_interface/query_snapshot.dart';
part 'src/method_channel_query_snapshot.dart';

part 'src/snapshot_metadata.dart';

part 'src/source.dart';

part 'src/timestamp.dart';

part 'src/transaction.dart';

part 'src/transaction_platform_interface.dart';

part 'src/write_batch.dart';

part 'src/write_batch_platform_interface.dart';

abstract class FirestorePlatform {

  FirestorePlatform();
  /// Only mock implementations should set this to `true`.
  ///
  /// Mockito mocks implement this class with `implements` which is forbidden
  /// (see class docs). This property provides a backdoor for mocks to skip the
  /// verification that the class isn't implemented with `implements`.
  @visibleForTesting
  bool get isMock => false;

  static FirestorePlatform get instance => _instance;

  static FirestorePlatform _instance = MethodChannelFirestore();

  factory FirestorePlatform._withApp(PlatformFirebaseApp app) =>
      MethodChannelFirestore();

  // TODO(amirh): Extract common platform interface logic.
  // https://github.com/flutter/flutter/issues/43368
  static set instance(FirestorePlatform instance) {
    if (!instance.isMock) {
      try {
        instance._verifyProvidesDefaultImplementations();
      } on NoSuchMethodError catch (_) {
        throw AssertionError(
            'Platform interfaces must not be implemented with `implements`');
      }
    }
    _instance = instance;
  }

  String appName() {
    throw UnimplementedError("appName() not implemented");
  }

  /// This method ensures that [FirebaseAuthPlatform] isn't implemented with `implements`.
  ///
  /// See class docs for more details on why using `implements` to implement
  /// [FirebaseAuthPlatform] is forbidden.
  ///
  /// This private method is called by the [instance] setter, which should fail
  /// if the provided instance is a class implemented with `implements`.
  void _verifyProvidesDefaultImplementations() {}

  /// Gets a [CollectionReference] for the specified Firestore path.
  CollectionReference collection(String path) {
    throw UnimplementedError('collection() is not implemented');
  }

  /// Gets a [Query] for the specified collection group.
  Query collectionGroup(String path) {
    throw UnimplementedError('collectionGroup() is not implemented');
  }

  /// Gets a [DocumentReference] for the specified Firestore path.
  DocumentReference document(String path) {
    throw UnimplementedError('document() is not implemented');
  }

  /// Creates a write batch, used for performing multiple writes as a single
  /// atomic operation.
  ///
  /// Unlike transactions, write batches are persisted offline and therefore are
  /// preferable when you don’t need to condition your writes on read data.
  WriteBatch batch() {
    throw UnimplementedError('batch() is not implemented');
  }

  /// Executes the given TransactionHandler and then attempts to commit the
  /// changes applied within an atomic transaction.
  ///
  /// In the TransactionHandler, a set of reads and writes can be performed
  /// atomically using the Transaction object passed to the TransactionHandler.
  /// After the TransactionHandler is run, Firestore will attempt to apply the
  /// changes to the server. If any of the data read has been modified outside
  /// of this transaction since being read, then the transaction will be
  /// retried by executing the updateBlock again. If the transaction still
  /// fails after 5 retries, then the transaction will fail.
  ///
  /// The TransactionHandler may be executed multiple times, it should be able
  /// to handle multiple executions.
  ///
  /// Data accessed with the transaction will not reflect local changes that
  /// have not been committed. For this reason, it is required that all
  /// reads are performed before any writes. Transactions must be performed
  /// while online. Otherwise, reads will fail, and the final commit will fail.
  ///
  /// By default transactions are limited to 5 seconds of execution time. This
  /// timeout can be adjusted by setting the timeout parameter.
  Future<Map<String, dynamic>> runTransaction(
      TransactionHandler transactionHandler,
      {Duration timeout = const Duration(seconds: 5)}) async {
    throw UnimplementedError('runTransaction() is not implemented');
  }

  @deprecated
  Future<void> enablePersistence(bool enable) async {
    throw UnimplementedError('enablePersistence() is not implemented');
  }

  Future<void> settings({bool persistenceEnabled,
    String host,
    bool sslEnabled,
    int cacheSizeBytes}) async {
    throw UnimplementedError('settings() is not implemented');
  }
}
