library cloud_firestore_web;

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:firebase/firebase.dart' as firebase;
import 'package:firebase/firestore.dart' show Firestore, Settings;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:firebase/firestore.dart' as web;

part 'collection_reference_web.dart';
part 'field_value_factory_web.dart';
part 'document_reference_web.dart';
part 'query_web.dart';
part 'transaction_web.dart';
part 'field_value_web.dart';
part 'write_batch_web.dart';

class FirestoreWeb extends FirestorePlatform {
  final Firestore webFirestore;

  static void registerWith(Registrar registrar) {
    FirestorePlatform.instance = FirestoreWeb();
    FieldValueFactory.instance = FieldValueFactoryWeb();
  }

  FirestoreWeb({FirebaseApp app})
      : webFirestore = firebase
            .firestore(firebase.app((app ?? FirebaseApp.instance).name)),
        super(app: app ?? FirebaseApp.instance);

  @override
  FirestorePlatform withApp(FirebaseApp app) => FirestoreWeb(app: app);

  @override
  CollectionReference collection(String path) {
    return CollectionReferenceWeb(this, webFirestore, path.split('/'));
  }

  @override
  Query collectionGroup(String path) {
    return QueryWeb(this, path, webFirestore.collectionGroup(path),
        isCollectionGroup: true);
  }

  @override
  DocumentReference document(String path) =>
      DocumentReferenceWeb(webFirestore, this, path.split('/'));

  @override
  WriteBatch batch() => WriteBatchWeb._(webFirestore.batch());

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
    return Future.sync(() {
      webFirestore.settings(Settings(
          ssl: sslEnabled, cacheSizeBytes: cacheSizeBytes, host: host));
    });
  }

  @override
  Future<Map<String, dynamic>> runTransaction(
      TransactionHandler transactionHandler,
      {Duration timeout = const Duration(seconds: 5)}) async {
    await webFirestore.runTransaction((transaction) async {
      return await transactionHandler(TransactionWeb._(transaction, this));
    }).timeout(timeout);
    return <String,dynamic>{};
  }

  @override
  String appName() => app.name;
}
