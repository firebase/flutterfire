import 'dart:js' as js;
import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:cloud_firestore_web/firestore_web.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase/firestore.dart' as web;

const kCollectionId = "test";

class MockFirestoreWeb extends Mock implements web.Firestore {}

class MockDocumentReference extends Mock implements web.DocumentReference {}

class MockQueryWeb extends Mock implements QueryWeb {}

class MockDocumentSnapshot extends Mock implements DocumentSnapshot {}

web.Firestore mockFirestore() {
  final mockFirestoreWeb = MockFirestoreWeb();
  final js.JsObject firebaseMock = js.JsObject.jsify(<String, dynamic>{
    'firestore': js.allowInterop((_) => mockFirestoreWeb),
    'app': js.allowInterop((String name) {
      return js.JsObject.jsify(<String, dynamic>{
        'name': name,
        'options': <String, String>{'appId': '123'},
      });
    })
  });
  js.context['firebase'] = firebaseMock;
  FirebaseCorePlatform.instance = FirebaseCoreWeb();
  FirestorePlatform.instance = FirestoreWeb();
  return mockFirestoreWeb;
}
