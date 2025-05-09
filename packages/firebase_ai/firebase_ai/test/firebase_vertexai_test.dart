// Copyright 2024 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mock.dart';

void main() {
  setupFirebaseVertexAIMocks();
  // ignore: unused_local_variable
  late FirebaseApp app;
  // ignore: unused_local_variable
  late FirebaseAppCheck appCheck;
  late FirebaseApp customApp;
  late FirebaseAppCheck customAppCheck;

  group('FirebaseAI Tests', () {
    late FirebaseApp app;

    setUpAll(() async {
      // Initialize Firebase
      app = await Firebase.initializeApp();
      customApp = await Firebase.initializeApp(
        name: 'custom-app',
        options: Firebase.app().options,
      );
      appCheck = FirebaseAppCheck.instance;
      customAppCheck = FirebaseAppCheck.instanceFor(app: customApp);
    });

    test('Singleton behavior', () {
      final instance1 = FirebaseAI.vertexAI();
      final instance2 = FirebaseAI.vertexAI(app: app);
      expect(identical(instance1, instance2), isTrue);
    });

    test('Instance creation with defaults', () {
      final vertexAI = FirebaseAI.vertexAI(app: app);
      expect(vertexAI.app, equals(app));
      expect(vertexAI.location, equals('us-central1'));
    });

    test('Instance creation with custom', () {
      final vertexAI = FirebaseAI.vertexAI(
          app: customApp,
          appCheck: customAppCheck,
          location: 'custom-location');
      expect(vertexAI.app, equals(customApp));
      expect(vertexAI.appCheck, equals(customAppCheck));
      expect(vertexAI.location, equals('custom-location'));
    });

    test('generativeModel creation', () {
      final vertexAI = FirebaseAI.vertexAI();

      final model = vertexAI.generativeModel(
        model: 'gemini-pro',
        generationConfig: GenerationConfig(maxOutputTokens: 1024),
        systemInstruction: Content.system('You are a helpful assistant.'),
      );

      expect(model, isA<GenerativeModel>());
    });

    // ... other tests (e.g., with different parameters)
  });
}
