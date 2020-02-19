// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:firebase/firebase.dart' as firebase;
import 'package:firebase/firestore.dart' show Firestore, Settings;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'package:cloud_firestore_web/src/collection_reference_web.dart';
import 'package:cloud_firestore_web/src/field_value_factory_web.dart';
import 'package:cloud_firestore_web/src/document_reference_web.dart';
import 'package:cloud_firestore_web/src/query_web.dart';
import 'package:cloud_firestore_web/src/transaction_web.dart';
import 'package:cloud_firestore_web/src/write_batch_web.dart';

/// Web implementation for [FirestorePlatform]
/// delegates calls to firestore web plugin
class FirestoreWeb extends FirestorePlatform {
  /// instance of Firestore from the web plugin
  final Firestore _webFirestore;

  /// Called by PluginRegistry to register this plugin for Flutter Web
  static void registerWith(Registrar registrar) {
    FirestorePlatform.instance = FirestoreWeb();
  }

  /// Builds an instance of [CloudFirestoreWeb] with an optional [FirebaseApp] instance
  /// If [app] is null then the created instance will use the default [FirebaseApp]
  FirestoreWeb({FirebaseApp app})
      : _webFirestore = firebase
            .firestore(firebase.app((app ?? FirebaseApp.instance).name)),
        super(app: app ?? FirebaseApp.instance) {
    FieldValueFactoryPlatform.instance = FieldValueFactoryWeb();
  }

  @override
  FirestorePlatform withApp(FirebaseApp app) => FirestoreWeb(app: app);

  @override
  CollectionReferencePlatform collection(String path) {
    return CollectionReferenceWeb(this, _webFirestore, path.split('/'));
  }

  @override
  QueryPlatform collectionGroup(String path) {
    return QueryWeb(this, path, _webFirestore.collectionGroup(path),
        isCollectionGroup: true);
  }

  @override
  DocumentReferencePlatform document(String path) =>
      DocumentReferenceWeb(_webFirestore, this, path.split('/'));

  @override
  WriteBatchPlatform batch() => WriteBatchWeb(_webFirestore.batch());

  @override
  Future<void> enablePersistence(bool enable) async {
    if (enable) {
      await _webFirestore.enablePersistence();
    }
  }

  @override
  Future<void> settings(
      {bool persistenceEnabled,
      String host,
      bool sslEnabled,
      int cacheSizeBytes}) async {
    if (host != null && sslEnabled != null) {
      _webFirestore.settings(Settings(
          cacheSizeBytes: cacheSizeBytes ?? 40000000,
          host: host,
          ssl: sslEnabled));
    } else {
      _webFirestore
          .settings(Settings(cacheSizeBytes: cacheSizeBytes ?? 40000000));
    }
    if (persistenceEnabled) {
      await _webFirestore.enablePersistence();
    }
  }

  @override
  Future<Map<String, dynamic>> runTransaction(
      TransactionHandler transactionHandler,
      {Duration timeout = const Duration(seconds: 5)}) async {
    Map<String, dynamic> result;
    await _webFirestore.runTransaction((transaction) async {
      result = await transactionHandler(TransactionWeb(transaction, this));
    }).timeout(timeout);
    return result is Map<String, dynamic> ? result : <String, dynamic>{};
  }
}
