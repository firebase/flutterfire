import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:cloud_firestore_web/collection_reference_web.dart';
import 'package:cloud_firestore_web/document_reference_web.dart';
import 'package:cloud_firestore_web/query_web.dart';
import 'package:firebase/firebase.dart' as firebase;
import 'package:firebase/firestore.dart' show Settings;
import 'package:flutter/cupertino.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

class FirestoreWeb extends FirestorePlatform {
  static void registerWith(Registrar registrar) {
    FirestorePlatform.instance = FirestoreWeb();
  }

  FirestoreWeb() : super();

  final app = firebase.firestore();

  @override
  CollectionReference collection(String path) {
    
    return CollectionReferenceWeb(this, app, path.split('/'));
  }


  @override
  Query collectionGroup(String path) {
    return QueryWeb(this, path,
        isCollectionGroup: true, webQuery: app.collectionGroup(path));
  }

  @override
  DocumentReference document(String path) =>
      DocumentReferenceWeb(app, this, path.split('/'));

  @override
  WriteBatch batch() => WriteBatch(this);

  @override
  Future<void> enablePersistence(bool enable) async {
    if (enable) {
      await app.enablePersistence();
    }
  }

  @override
  Future<void> settings(
      {bool persistenceEnabled,
      String host,
      bool sslEnabled,
      int cacheSizeBytes}) async {
    return Future.sync(() {
      
      app.settings(
        Settings(ssl: sslEnabled, cacheSizeBytes: cacheSizeBytes, host: host));
      
    });
  }

  @override
  Future<Map<String, dynamic>> runTransaction(transactionHandler,
      {Duration timeout = const Duration(seconds: 5)}) async {}

  @override
  String appName() => firebase.app().name;
}
