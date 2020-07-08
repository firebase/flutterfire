import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

import './mock.dart';

void main() {
  setupCloudFirestoreMocks();
  FirebaseFirestore firestore;

  setUpAll(() async {
    await Firebase.initializeApp();
    firestore = FirebaseFirestore.instance;
  });

  group("$Transaction", () {
    test('throws if invalid transactionHandler passed', () async {
      expect(() => firestore.runTransaction(null), throwsAssertionError);
    });
  });
}
