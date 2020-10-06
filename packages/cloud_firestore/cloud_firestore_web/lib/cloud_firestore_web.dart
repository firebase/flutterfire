// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:cloud_firestore_web/src/utils/exception.dart';
import 'package:firebase/firebase.dart' as firebase;
import 'package:firebase/firestore.dart' as web;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'package:cloud_firestore_web/src/collection_reference_web.dart';
import 'package:cloud_firestore_web/src/field_value_factory_web.dart';
import 'package:cloud_firestore_web/src/document_reference_web.dart';
import 'package:cloud_firestore_web/src/query_web.dart';
import 'package:cloud_firestore_web/src/transaction_web.dart';
import 'package:cloud_firestore_web/src/write_batch_web.dart';

/// Web implementation for [FirebaseFirestorePlatform]
/// delegates calls to firestore web plugin
class FirebaseFirestoreWeb extends FirebaseFirestorePlatform {
  /// instance of Firestore from the web plugin
  final web.Firestore _webFirestore;

  /// Called by PluginRegistry to register this plugin for Flutter Web
  static void registerWith(Registrar registrar) {
    FirebaseFirestorePlatform.instance = FirebaseFirestoreWeb();
  }

  /// Builds an instance of [FirebaseFirestoreWeb] with an optional [FirebaseApp] instance
  /// If [app] is null then the created instance will use the default [FirebaseApp]
  FirebaseFirestoreWeb({FirebaseApp app})
      : _webFirestore = firebase.firestore(firebase.app(app?.name)),
        super(appInstance: app) {
    FieldValueFactoryPlatform.instance = FieldValueFactoryWeb();
  }

  @override
  FirebaseFirestorePlatform delegateFor({FirebaseApp app}) {
    return FirebaseFirestoreWeb(app: app);
  }

  @override
  CollectionReferencePlatform collection(String path) {
    return CollectionReferenceWeb(this, _webFirestore, path);
  }

  @override
  WriteBatchPlatform batch() => WriteBatchWeb(_webFirestore);

  // @override
  // Future<void> clearPersistence() async {
  //   // TODO(ehesp): not supported on firebase-dart
  // }

  @override
  QueryPlatform collectionGroup(String path) {
    return QueryWeb(this, path, _webFirestore.collectionGroup(path),
        isCollectionGroupQuery: true);
  }

  @override
  Future<void> disableNetwork() async {
    try {
      await _webFirestore.disableNetwork();
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  @override
  DocumentReferencePlatform doc(String path) =>
      DocumentReferenceWeb(this, _webFirestore, path);

  @override
  Future<void> enableNetwork() async {
    try {
      await _webFirestore.enableNetwork();
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  // @override
  // Stream<void> snapshotsInSync() {
  //   // TODO(ehesp): not supported on firebase-dart
  // }

  @override
  Future<T> runTransaction<T>(TransactionHandler<T> transactionHandler,
      {Duration timeout = const Duration(seconds: 30)}) async {
    try {
      await _webFirestore.runTransaction((transaction) async {
        return transactionHandler(
            TransactionWeb(this, _webFirestore, transaction));
      }).timeout(timeout);

      return null;
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  @override
  set settings(Settings settings) {
    int cacheSizeBytes;

    if (settings.cacheSizeBytes == null) {
      cacheSizeBytes = 40000000;
    } else if (settings.cacheSizeBytes == Settings.CACHE_SIZE_UNLIMITED) {
      // https://github.com/firebase/firebase-js-sdk/blob/e67affba53a53d28492587b2f60521a00166db60/packages/firestore/src/local/lru_garbage_collector.ts#L175
      cacheSizeBytes = -1;
    } else {
      cacheSizeBytes = settings.cacheSizeBytes;
    }

    if (settings.host != null && settings.sslEnabled != null) {
      _webFirestore.settings(web.Settings(
          cacheSizeBytes: cacheSizeBytes,
          host: settings.host,
          ssl: settings.sslEnabled));
    } else {
      _webFirestore.settings(web.Settings(cacheSizeBytes: cacheSizeBytes));
    }
  }

  /// Enable persistence of Firestore data. Web only.
  Future<void> enablePersistence() async {
    // TODO(salakar): this should accept a [PersistenceSettings] argument
    // but it is currently unsupported on the 'firebase-dart' package.
    // See https://firebase.google.com/docs/reference/js/firebase.firestore.PersistenceSettings
    try {
      await _webFirestore.enablePersistence();
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  // @override
  // Future<void> terminate() async {
  //   // TODO(ehesp): not supported on firebase-dart
  // }

  // @override
  // Future<void> waitForPendingWrites() async {
  //   // TODO(ehesp): not supported on firebase-dart
  // }
}
