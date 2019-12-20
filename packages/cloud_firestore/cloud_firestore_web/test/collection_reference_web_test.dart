@TestOn('chrome')
import 'dart:js' as js;

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:cloud_firestore_web/firestore_web.dart';
import 'package:firebase/firebase.dart' as web;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:flutter_test/flutter_test.dart';

const _kCollectionId = "test";

void main() {
  group("$CollectionReferenceWeb()", () {
    CollectionReferenceWeb collectionReference;
    setUp((){
      final js.JsObject firebaseMock = js.JsObject.jsify(<String, dynamic>{});
      js.context['firebase'] = firebaseMock;
      js.context['firebase']['app'] = js.allowInterop((String name) {
        return js.JsObject.jsify(<String, dynamic>{
          'name': name,
          'options': <String, String>{'appId': '123'},
        });
      });
      js.context['firebase']['firestore'] = js.allowInterop((dynamic app) {});
      FirebaseCorePlatform.instance = FirebaseCoreWeb();
      FirestorePlatform.instance = FirestoreWeb();
      collectionReference = CollectionReferenceWeb(FirestorePlatform.instance ,
        web.firestore(web.app(FirestorePlatform.instance .appName())),
        [_kCollectionId]
      );
    });

    test("parent",(){
      expect(collectionReference.parent(), isNull);
      expect(CollectionReferenceWeb(
          FirestorePlatform.instance ,
          web.firestore(web.app(FirestorePlatform.instance .appName())),
          [_kCollectionId,_kCollectionId,_kCollectionId]
      ), isInstanceOf<DocumentReferenceWeb>());
    });
  });
}