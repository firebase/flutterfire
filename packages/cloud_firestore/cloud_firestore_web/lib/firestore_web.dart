library cloud_firestore_web;

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:firebase/firebase.dart' as firebase;
import 'package:firebase/firestore.dart' show Firestore, Settings;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:firebase/firestore.dart' as web;
import 'package:js/js_util.dart';
import 'package:meta/meta.dart';

part 'collection_reference_web.dart';
part 'utils/codec_utility.dart';
part 'utils/document_reference_utils.dart';
part 'field_value_factory_web.dart';
part 'document_reference_web.dart';
part 'query_web.dart';
part 'transaction_web.dart';
part 'field_value_web.dart';
part 'write_batch_web.dart';

/// Web implementation for [FirestorePlatform]
/// delegates calls to firestore web plugin
class FirestoreWeb extends FirestorePlatform {
  /// instance of Firestore from the web plugin
  final Firestore webFirestore;

  /// Called by PluginRegistry to register this plugin for Flutter Web
  static void registerWith(Registrar registrar) {
    FirestorePlatform.instance = FirestoreWeb();
  }

  /// Builds an instance of [FirestoreWeb] with an optional [FirebaseApp] instance
  /// If [app] is null then the created instance will use the default [FirebaseApp]
  FirestoreWeb({FirebaseApp app})
      : webFirestore = firebase
            .firestore(firebase.app((app ?? FirebaseApp.instance).name)),
        super(app: app ?? FirebaseApp.instance) {
    FieldValueFactoryPlatform.instance = FieldValueFactoryWeb();
  }

  @override
  FirestorePlatform withApp(FirebaseApp app) => FirestoreWeb(app: app);

  @override
  CollectionReferencePlatform collection(String path) {
    return CollectionReferenceWeb(this, webFirestore, path.split('/'));
  }

  @override
  QueryPlatform collectionGroup(String path) {
    return QueryWeb(this, path, webFirestore.collectionGroup(path),
        isCollectionGroup: true);
  }

  @override
  DocumentReferencePlatform document(String path) =>
      DocumentReferenceWeb(webFirestore, this, path.split('/'));

  @override
  WriteBatchPlatform batch() => WriteBatchWeb(webFirestore.batch());

  @override
  Future<void> enablePersistence(bool enable) async {
    if (enable) {
      await webFirestore.enablePersistence();
    }
  }

  @override
  Future<void> settings(
      {bool persistenceEnabled,
      String host,
      bool sslEnabled,
      int cacheSizeBytes}) async {
    if (host != null && sslEnabled != null) {
      webFirestore.settings(Settings(
          cacheSizeBytes: cacheSizeBytes ?? 40000000,
          host: host,
          ssl: sslEnabled));
    } else {
      webFirestore
          .settings(Settings(cacheSizeBytes: cacheSizeBytes ?? 40000000));
    }
    if (persistenceEnabled) {
      await webFirestore.enablePersistence();
    }
  }

  @override
  Future<Map<String, dynamic>> runTransaction(
      TransactionHandler transactionHandler,
      {Duration timeout = const Duration(seconds: 5)}) async {
    Map<String, dynamic> result;
    await webFirestore.runTransaction((transaction) async {
      result = await transactionHandler(TransactionWeb(transaction, this));
    }).timeout(timeout);
    return result is Map<String, dynamic> ? result : <String, dynamic>{};
  }
}
