// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:typed_data';

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:cloud_firestore_web/src/internals.dart';
import 'package:cloud_firestore_web/src/load_bundle_task_web.dart';
import 'package:cloud_firestore_web/src/utils/web_utils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_web/firebase_core_web_interop.dart'
    as core_interop;
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'src/collection_reference_web.dart';
import 'src/field_value_factory_web.dart';
import 'src/document_reference_web.dart';
import 'src/query_web.dart';
import 'src/transaction_web.dart';
import 'src/write_batch_web.dart';
import 'src/interop/firestore.dart' as firestore_interop;

/// Web implementation for [FirebaseFirestorePlatform]
/// delegates calls to firestore web plugin
class FirebaseFirestoreWeb extends FirebaseFirestorePlatform {
  /// instance of Firestore from the web plugin
  final firestore_interop.Firestore _webFirestore;

  /// Called by PluginRegistry to register this plugin for Flutter Web
  static void registerWith(Registrar registrar) {
    FirebaseFirestorePlatform.instance = FirebaseFirestoreWeb();
  }

  /// Builds an instance of [FirebaseFirestoreWeb] with an optional [FirebaseApp] instance
  /// If [app] is null then the created instance will use the default [FirebaseApp]
  FirebaseFirestoreWeb({FirebaseApp? app})
      : _webFirestore =
            firestore_interop.getFirestoreInstance(core_interop.app(app?.name)),
        super(appInstance: app) {
    FieldValueFactoryPlatform.instance = FieldValueFactoryWeb();
  }

  @override
  FirebaseFirestorePlatform delegateFor(
      {/*required*/ required FirebaseApp app}) {
    return FirebaseFirestoreWeb(app: app);
  }

  @override
  CollectionReferencePlatform collection(String collectionPath) {
    return CollectionReferenceWeb(this, _webFirestore, collectionPath);
  }

  @override
  WriteBatchPlatform batch() => WriteBatchWeb(_webFirestore);

  @override
  Future<void> clearPersistence() {
    return guard(_webFirestore.clearPersistence);
  }

  @override
  void useEmulator(String host, int port) {
    return _webFirestore.useEmulator(host, port);
  }

  @override
  QueryPlatform collectionGroup(String collectionPath) {
    return QueryWeb(
        this, collectionPath, _webFirestore.collectionGroup(collectionPath),
        isCollectionGroupQuery: true);
  }

  @override
  Future<void> disableNetwork() {
    return guard(_webFirestore.disableNetwork);
  }

  @override
  DocumentReferencePlatform doc(String documentPath) =>
      DocumentReferenceWeb(this, _webFirestore, documentPath);

  @override
  Future<void> enableNetwork() {
    return guard(_webFirestore.enableNetwork);
  }

  @override
  Stream<void> snapshotsInSync() {
    return _webFirestore.snapshotsInSync();
  }

  @override
  Future<T?> runTransaction<T>(TransactionHandler<T> transactionHandler,
      {Duration timeout = const Duration(seconds: 30)}) async {
    await guard(() {
      return _webFirestore.runTransaction((transaction) async {
        return transactionHandler(
            TransactionWeb(this, _webFirestore, transaction!));
      }).timeout(timeout);
    });
    // Workaround for 'Runtime type information not available for type_variable_local'
    // See: https://github.com/dart-lang/sdk/issues/29722

    return null;
  }

  @override
  set settings(Settings settings) {
    int? cacheSizeBytes;

    if (settings.cacheSizeBytes == null) {
      cacheSizeBytes = 40000000;
    } else if (settings.cacheSizeBytes == Settings.CACHE_SIZE_UNLIMITED) {
      // https://github.com/firebase/firebase-js-sdk/blob/e67affba53a53d28492587b2f60521a00166db60/packages/firestore/src/local/lru_garbage_collector.ts#L175
      cacheSizeBytes = -1;
    } else {
      cacheSizeBytes = settings.cacheSizeBytes;
    }

    if (settings.host != null && settings.sslEnabled != null) {
      _webFirestore.settings(firestore_interop.Settings(
          cacheSizeBytes: cacheSizeBytes,
          host: settings.host,
          ssl: settings.sslEnabled));
    } else {
      _webFirestore
          .settings(firestore_interop.Settings(cacheSizeBytes: cacheSizeBytes));
    }
  }

  /// Enable persistence of Firestore data.
  @override
  Future<void> enablePersistence([PersistenceSettings? settings]) {
    return guard(_webFirestore.enablePersistence);
  }

  @override
  Future<void> terminate() {
    return guard(_webFirestore.terminate);
  }

  @override
  Future<void> waitForPendingWrites() {
    return guard(_webFirestore.waitForPendingWrites);
  }

  @override
  LoadBundleTaskPlatform loadBundle(Uint8List bundle) {
    return LoadBundleTaskWeb(_webFirestore.loadBundle(bundle));
  }

  @override
  Future<QuerySnapshotPlatform> namedQueryGet(
    String name, {
    GetOptions options = const GetOptions(),
  }) async {
    firestore_interop.Query? query = await _webFirestore.namedQuery(name);
    firestore_interop.QuerySnapshot snapshot =
        await query.get(convertGetOptions(options));

    return convertWebQuerySnapshot(this, snapshot);
  }
}
