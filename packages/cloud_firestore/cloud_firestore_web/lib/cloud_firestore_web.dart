// ignore_for_file: require_trailing_commas
// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:cloud_firestore_web/src/internals.dart';
import 'package:cloud_firestore_web/src/load_bundle_task_web.dart';
import 'package:cloud_firestore_web/src/utils/web_utils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:firebase_core_web/firebase_core_web_interop.dart'
    as core_interop;
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'src/collection_reference_web.dart';
import 'src/document_reference_web.dart';
import 'src/field_value_factory_web.dart';
import 'src/interop/firestore.dart' as firestore_interop;
import 'src/query_web.dart';
import 'src/transaction_web.dart';
import 'src/write_batch_web.dart';

/// Web implementation for [FirebaseFirestorePlatform]
/// delegates calls to firestore web plugin
class FirebaseFirestoreWeb extends FirebaseFirestorePlatform {
  /// instance of Firestore from the web plugin
  firestore_interop.Firestore? _webFirestore;

  firestore_interop.FirestoreSettings? _settings;

  /// Lazily initialize [_webFirestore] on first method call
  firestore_interop.Firestore get _delegate {
    return _webFirestore ??= firestore_interop.getFirestoreInstance(
        core_interop.app(app.name), _settings, databaseId);
  }

  /// Called by PluginRegistry to register this plugin for Flutter Web
  static void registerWith(Registrar registrar) {
    FirebaseCoreWeb.registerService('firestore');
    FirebaseFirestorePlatform.instance = FirebaseFirestoreWeb();
  }

  /// Builds an instance of [FirebaseFirestoreWeb] with an optional [FirebaseApp] instance
  /// If [app] is null then the created instance will use the default [FirebaseApp]
  FirebaseFirestoreWeb({FirebaseApp? app, String? databaseId})
      : super(appInstance: app, databaseChoice: databaseId) {
    FieldValueFactoryPlatform.instance = FieldValueFactoryWeb();
  }

  @override
  FirebaseFirestorePlatform delegateFor(
      {required FirebaseApp app, required String databaseId}) {
    return FirebaseFirestoreWeb(app: app, databaseId: databaseId);
  }

  @override
  CollectionReferencePlatform collection(String collectionPath) {
    return CollectionReferenceWeb(this, _delegate, collectionPath);
  }

  @override
  WriteBatchPlatform batch() => WriteBatchWeb(_delegate);

  @override
  Future<void> clearPersistence() {
    return convertWebExceptions(_delegate.clearPersistence);
  }

  @override
  void useEmulator(String host, int port) {
    return _delegate.useEmulator(host, port);
  }

  @override
  QueryPlatform collectionGroup(String collectionPath) {
    return QueryWeb(
        this, collectionPath, _delegate.collectionGroup(collectionPath),
        isCollectionGroupQuery: true);
  }

  @override
  Future<void> disableNetwork() {
    return convertWebExceptions(_delegate.disableNetwork);
  }

  @override
  DocumentReferencePlatform doc(String documentPath) =>
      DocumentReferenceWeb(this, _delegate, documentPath);

  @override
  Future<void> enableNetwork() {
    return convertWebExceptions(_delegate.enableNetwork);
  }

  @override
  Stream<void> snapshotsInSync() {
    return _delegate.snapshotsInSync();
  }

  @override
  Future<T?> runTransaction<T>(
    TransactionHandler<T> transactionHandler, {
    Duration timeout = const Duration(seconds: 30),
    int maxAttempts = 5,
  }) async {
    await convertWebExceptions(() {
      return _delegate
          .runTransaction(
            (transaction) async => transactionHandler(
              TransactionWeb(this, _delegate, transaction!),
            ),
            maxAttempts,
          )
          .timeout(timeout);
    });
    // Workaround for 'Runtime type information not available for type_variable_local'
    // See: https://github.com/dart-lang/sdk/issues/29722

    return null;
  }

  @override
  Settings get settings {
    return const Settings();
  }

  @override
  set settings(Settings settings) {
    // Union type MemoryLocalCache | PersistentLocalCache
    dynamic localCache;
    final persistenceEnabled = settings.persistenceEnabled;
    if (persistenceEnabled == null || persistenceEnabled == false) {
      localCache = firestore_interop.memoryLocalCache(null);
    } else {
      localCache = firestore_interop
          .persistentLocalCache(firestore_interop.PersistentCacheSettings(
        cacheSizeBytes: settings.cacheSizeBytes?.toJS,
      ));
    }

    if (settings.host != null && settings.sslEnabled != null) {
      _settings = firestore_interop.FirestoreSettings(
        localCache: localCache,
        host: settings.host?.toJS,
        ssl: settings.sslEnabled?.toJS,
        ignoreUndefinedProperties: settings.ignoreUndefinedProperties.toJS,
      );
    } else {
      _settings = firestore_interop.FirestoreSettings(
        localCache: localCache,
        ignoreUndefinedProperties: settings.ignoreUndefinedProperties.toJS,
      );
    }
  }

  /// Enable persistence of Firestore data.
  @override
  Future<void> enablePersistence([PersistenceSettings? settings]) {
    if (settings != null) {
      firestore_interop.PersistenceSettings interopSettings =
          firestore_interop.PersistenceSettings(
              synchronizeTabs: settings.synchronizeTabs.toJS);

      return convertWebExceptions(
          () => _delegate.enablePersistence(interopSettings));
    }

    return convertWebExceptions(_delegate.enablePersistence);
  }

  @override
  Future<void> terminate() {
    return convertWebExceptions(_delegate.terminate);
  }

  @override
  Future<void> waitForPendingWrites() {
    return convertWebExceptions(_delegate.waitForPendingWrites);
  }

  @override
  LoadBundleTaskPlatform loadBundle(Uint8List bundle) {
    return LoadBundleTaskWeb(_delegate.loadBundle(bundle));
  }

  @override
  Future<QuerySnapshotPlatform> namedQueryGet(
    String name, {
    GetOptions options = const GetOptions(),
  }) async {
    firestore_interop.Query? query = await _delegate.namedQuery(name);
    firestore_interop.QuerySnapshot snapshot =
        await query.get(convertGetOptions(options));

    return convertWebQuerySnapshot(
      this,
      snapshot,
      options.serverTimestampBehavior,
    );
  }

  @override
  Future<void> setIndexConfiguration(String indexConfiguration) async {
    return _delegate.setIndexConfiguration(
      indexConfiguration,
    );
  }

  @override
  Future<void> setLoggingEnabled(bool enabled) async {
    late final String value;
    if (enabled) {
      value = 'debug';
    } else {
      value = 'silent';
    }
    _delegate.setLoggingEnabled(value);
  }
}
