import 'package:flutter_test/flutter_test.dart';

import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
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

    test('text prompt, no streaming', () async {
      final model = vertexAI.generativeModel(model: "gemini-1.5-pro");
      final content = [Content.text('Write a story about a magic backpack.')];
      final response = await model.generateContent(content);

      expect(response.text!.isNotEmpty, true);
    });
  });
}
