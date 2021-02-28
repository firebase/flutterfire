// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:cloud_firestore_web/src/utils/exception.dart';
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
  Future<void> clearPersistence() async {
    try {
      await _webFirestore.clearPersistence();
    } catch (e) {
      throw getFirebaseException(e);
    }
  }

  @override
  QueryPlatform collectionGroup(String collectionPath) {
    return QueryWeb(
        this, collectionPath, _webFirestore.collectionGroup(collectionPath),
        isCollectionGroupQuery: true);
  }

  @override
  Future<void> disableNetwork() async {
    try {
      await _webFirestore.disableNetwork();
    } catch (e) {
      throw getFirebaseException(e);
    }
  }

  @override
  DocumentReferencePlatform doc(String documentPath) =>
      DocumentReferenceWeb(this, _webFirestore, documentPath);

  @override
  Future<void> enableNetwork() async {
    try {
      await _webFirestore.enableNetwork();
    } catch (e) {
      throw getFirebaseException(e);
    }
  }

  @override
  Stream<void> snapshotsInSync() {
    return _webFirestore.snapshotsInSync();
  }

  @override
  Future<T?> runTransaction<T>(TransactionHandler<T> transactionHandler,
      {Duration timeout = const Duration(seconds: 30)}) async {
    try {
      await _webFirestore.runTransaction((transaction) async {
        return transactionHandler(
            TransactionWeb(this, _webFirestore, transaction!));
      }).timeout(timeout);
      // Workaround for 'Runtime type information not available for type_variable_local'
      // See: https://github.com/dart-lang/sdk/issues/29722
      return null;
    } catch (e) {
      throw getFirebaseException(e);
    }
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
  Future<void> enablePersistence([PersistenceSettings? settings]) async {
    try {
      await _webFirestore.enablePersistence(
          firestore_interop.PersistenceSettings(
              synchronizeTabs: settings?.synchronizeTabs ?? false));
    } catch (e) {
      throw getFirebaseException(e);
    }
  }

  @override
  Future<void> terminate() async {
    try {
      await _webFirestore.terminate();
    } catch (e) {
      throw getFirebaseException(e);
    }
  }

  @override
  Future<void> waitForPendingWrites() async {
    try {
      await _webFirestore.waitForPendingWrites();
    } catch (e) {
      throw getFirebaseException(e);
    }
  }
}
