import 'package:flutter_test/flutter_test.dart';

import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:firebase_core/firebase_core.dart';

import 'vertex_mock.dart';

void main() {
  setupFirebaseVertexAIMocks();
  late FirebaseApp app;
  late FirebaseVertexAI vertexAI;
  group('$FirebaseVertexAI', () {
    setUpAll(() async {
      app = await Firebase.initializeApp();

      vertexAI = FirebaseVertexAI.instance;
    });

    test('instance', () async {
      expect(vertexAI, isA<FirebaseVertexAI>());
      expect(vertexAI, equals(FirebaseVertexAI.instance));
    });

    test('returns the correct $FirebaseApp', () {
      expect(vertexAI.app, isA<FirebaseApp>());
    });
  });
}
