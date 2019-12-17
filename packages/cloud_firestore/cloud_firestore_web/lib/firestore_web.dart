import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:cloud_firestore_web/collection_reference_web.dart';
import 'package:cloud_firestore_web/document_reference_web.dart';
import 'package:cloud_firestore_web/query_web.dart';
import 'package:firebase/firebase.dart' as firebase;
import 'package:firebase/firestore.dart' show Firestore, Settings;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

class FirestoreWeb extends FirestorePlatform {

  final Firestore webFirestore;

  static void registerWith(Registrar registrar) {
    FirestorePlatform.instance = FirestoreWeb();

  }

  FirestoreWeb({FirebaseApp app}): webFirestore = firebase.firestore(firebase.app((app ?? FirebaseApp.instance).name)),super(app: app ?? FirebaseApp.instance);

  @override
  FirestorePlatform withApp(FirebaseApp app) => FirestoreWeb(app: app);

  @override
  CollectionReference collection(String path) {
    return CollectionReferenceWeb(
        this, webFirestore, path.split('/'));
  }

  @override
  Query collectionGroup(String path) {
    return QueryWeb(this, path,
        isCollectionGroup: true, webQuery: webFirestore.collectionGroup(path));
  }

  @override
  DocumentReference document(String path) =>
      DocumentReferenceWeb(webFirestore, this, path.split('/'));

  @override
  WriteBatch batch() => WriteBatch(this);

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
  Future<Map<String, dynamic>> runTransaction(transactionHandler,
      {Duration timeout = const Duration(seconds: 5)}) async {}

  @override
  String appName() => app.name;
}
