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

import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'mock.dart';

void main() {
  setupFirebaseVertexAIMocks();
  // ignore: unused_local_variable
  late FirebaseApp app;
  // ignore: unused_local_variable
  late FirebaseAppCheck appCheck;
  late FirebaseApp customApp;
  late FirebaseApp limitTokenApp;
  late FirebaseAppCheck customAppCheck;
  late FirebaseAuth customAuth;
  late FirebaseAppCheck limitTokenAppCheck;

  group('FirebaseAI Tests', () {
    late FirebaseApp app;

    setUpAll(() async {
      // Initialize Firebase
      app = await Firebase.initializeApp();
      customApp = await Firebase.initializeApp(
        name: 'custom-app',
        options: Firebase.app().options,
      );
      limitTokenApp = await Firebase.initializeApp(
        name: 'limit-token-app',
        options: Firebase.app().options,
      );
      appCheck = FirebaseAppCheck.instance;
      customAppCheck = FirebaseAppCheck.instanceFor(app: customApp);
      limitTokenAppCheck = FirebaseAppCheck.instanceFor(app: limitTokenApp);
      customAuth = FirebaseAuth.instanceFor(app: customApp);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler(
        'dev.flutter.pigeon.firebase_app_check_platform_interface.'
        'FirebaseAppCheckHostApi.getToken',
        (_) async {
          return const StandardMessageCodec().encodeMessage(
            <Object?>['app-check-token'],
          );
        },
      );
    });

    group('agentPlatform tests', () {
      test('Singleton behavior', () {
        final instance1 = FirebaseAI.agentPlatform();
        final instance2 = FirebaseAI.agentPlatform(app: app);
        expect(identical(instance1, instance2), isTrue);
      });

      test('Instance creation with defaults', () {
        final agentPlatform = FirebaseAI.agentPlatform(app: app);
        expect(agentPlatform.app, equals(app));
        expect(agentPlatform.location, equals('global'));
      });

      test('Instance creation with custom location', () {
        final agentPlatform = FirebaseAI.agentPlatform(
          app: customApp,
          location: 'custom-location',
        );
        expect(agentPlatform.app, equals(customApp));
        expect(agentPlatform.appCheck, equals(customAppCheck));
        expect(agentPlatform.location, equals('custom-location'));
      });

      test('generativeModel creation', () {
        final agentPlatform = FirebaseAI.agentPlatform();

        final model = agentPlatform.generativeModel(
          model: 'gemini-pro',
          generationConfig: GenerationConfig(maxOutputTokens: 1024),
          systemInstruction: Content.system('You are a helpful assistant.'),
        );

        expect(model, isA<GenerativeModel>());
      });

      test('Instance creation with useLimitedUseAppCheckTokens', () {
        final agentPlatform = FirebaseAI.agentPlatform(
          app: limitTokenApp,
          location: 'limit-token-location',
          useLimitedUseAppCheckTokens: true,
        );
        expect(agentPlatform.app, equals(limitTokenApp));
        expect(agentPlatform.appCheck, equals(limitTokenAppCheck));
        expect(agentPlatform.location, equals('limit-token-location'));
        expect(agentPlatform.useLimitedUseAppCheckTokens, true);
      });

      test('Instance creation with auto-injected AppCheck', () {
        final agentPlatform = FirebaseAI.agentPlatform(app: customApp);

        expect(agentPlatform.app, equals(customApp));
        expect(agentPlatform.appCheck, equals(customAppCheck));
      });

      test('Instance creation with auto-injected Auth', () {
        final agentPlatform = FirebaseAI.agentPlatform(app: customApp);

        expect(agentPlatform.app, equals(customApp));
        expect(agentPlatform.auth, equals(customAuth));
      });
    });

    group('Deprecated vertexAI tests', () {
      // ignore: deprecated_member_use_from_same_package
      test('Singleton behavior', () {
        // ignore: deprecated_member_use_from_same_package
        final instance1 = FirebaseAI.vertexAI();
        // ignore: deprecated_member_use_from_same_package
        final instance2 = FirebaseAI.vertexAI(app: app);
        expect(identical(instance1, instance2), isTrue);
      });

      // ignore: deprecated_member_use_from_same_package
      test('Instance creation with defaults', () {
        // ignore: deprecated_member_use_from_same_package
        final vertexAI = FirebaseAI.vertexAI(app: app);
        expect(vertexAI.app, equals(app));
        expect(vertexAI.location, equals('us-central1'));
      });

      // ignore: deprecated_member_use_from_same_package
      test('Instance creation with custom', () {
        // ignore: deprecated_member_use_from_same_package
        final vertexAI = FirebaseAI.vertexAI(
            app: customApp,
            appCheck: customAppCheck,
            location: 'custom-location');
        expect(vertexAI.app, equals(customApp));
        expect(vertexAI.appCheck, equals(customAppCheck));
        expect(vertexAI.location, equals('custom-location'));
      });

      // ignore: deprecated_member_use_from_same_package
      test('generativeModel creation', () {
        // ignore: deprecated_member_use_from_same_package
        final vertexAI = FirebaseAI.vertexAI();

        final model = vertexAI.generativeModel(
          model: 'gemini-pro',
          generationConfig: GenerationConfig(maxOutputTokens: 1024),
          systemInstruction: Content.system('You are a helpful assistant.'),
        );

        expect(model, isA<GenerativeModel>());
      });

      // ignore: deprecated_member_use_from_same_package
      test('Instance creation with useLimitedUseAppCheckTokens', () {
        // ignore: deprecated_member_use_from_same_package
        final vertexAIAppCheck = FirebaseAI.vertexAI(
          app: limitTokenApp,
          appCheck: limitTokenAppCheck,
          location: 'limit-token-location',
          useLimitedUseAppCheckTokens: true,
        );
        expect(vertexAIAppCheck.app, equals(limitTokenApp));
        expect(vertexAIAppCheck.appCheck, equals(limitTokenAppCheck));
        expect(vertexAIAppCheck.location, equals('limit-token-location'));
        expect(vertexAIAppCheck.useLimitedUseAppCheckTokens, true);
      });

      // ignore: deprecated_member_use_from_same_package
      test('Instance creation with auto-injected AppCheck', () {
        // ignore: deprecated_member_use_from_same_package
        final vertexAI = FirebaseAI.vertexAI(app: customApp);

        expect(vertexAI.app, equals(customApp));
        expect(vertexAI.appCheck, equals(customAppCheck));
      });

      // ignore: deprecated_member_use_from_same_package
      test('Instance creation with auto-injected Auth', () {
        // ignore: deprecated_member_use_from_same_package
        final vertexAI = FirebaseAI.vertexAI(app: customApp);

        expect(vertexAI.app, equals(customApp));
        expect(vertexAI.auth, equals(customAuth));
      });
    });

    test('generativeModel creation with Grounding tools', () {
      final ai = FirebaseAI.googleAI();

      final model = ai.generativeModel(
        model: 'gemini-2.5-flash',
        tools: [Tool.googleMaps()],
        toolConfig: ToolConfig(
          retrievalConfig: RetrievalConfig(
            latLng: LatLng(latitude: 37.42, longitude: -122.08),
            languageCode: 'en-US',
          ),
        ),
      );

      expect(model, isA<GenerativeModel>());
    });

    test('generativeModel uses provided HTTP client', () async {
      final requests = <http.BaseRequest>[];
      final client = _RecordingClient((request) {
        requests.add(request);

        if (request.url.path.endsWith(':streamGenerateContent')) {
          return http.StreamedResponse(
            Stream.value(utf8.encode('data: ${jsonEncode(_response)}\n\n')),
            200,
          );
        }

        return http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode(_response))),
          200,
        );
      });
      final ai = FirebaseAI.googleAI(app: app);

      final model = ai.generativeModel(
        model: 'gemini-pro',
        httpClient: client,
      );

      await model.generateContent([Content.text('prompt')]);
      await model.generateContentStream([Content.text('prompt')]).drain<void>();

      expect(requests, hasLength(2));
      expect(
        requests.first.url.path,
        endsWith('/models/gemini-pro:generateContent'),
      );
      expect(
        requests.last.url.path,
        endsWith('/models/gemini-pro:streamGenerateContent'),
      );
    });
  });
}

class _RecordingClient extends http.BaseClient {
  _RecordingClient(this._handler);

  final http.StreamedResponse Function(http.BaseRequest request) _handler;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    return _handler(request);
  }
}

const _response = {
  'candidates': [
    {
      'content': {
        'role': 'model',
        'parts': [
          {'text': 'Some Response'},
        ],
      },
    },
  ],
};
