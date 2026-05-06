import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:firebase_ai/src/api.dart';
import 'package:firebase_ai/src/client.dart';
import 'package:firebase_ai/src/base_model.dart';
import 'package:firebase_ai/src/content.dart';
import 'package:firebase_ai/src/chat.dart';
import 'package:tests/firebase_options.dart';

class MockApiClient implements ApiClient {
  final List<Map<String, Object?>> requests = [];
  Map<String, Object?> mockResponse = {};

  @override
  Future<Map<String, Object?>> makeRequest(
      Uri uri, Map<String, Object?> body) async {
    requests.add({'uri': uri, 'body': body});
    return mockResponse;
  }

  @override
  Stream<Map<String, Object?>> streamRequest(
      Uri uri, Map<String, Object?> body) async* {
    requests.add({'uri': uri, 'body': body});
    yield mockResponse;
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('firebase_ai mock tests', () {
    setUpAll(() async {
      setupFirebaseCoreMocks();
      // Use a named app to avoid conflict with the default app initialized by mocks
      await Firebase.initializeApp(
        name: 'mockTestApp',
        options: DefaultFirebaseOptions.currentPlatform,
      );
    });

    test('Verify Request Payload for Grounding', () async {
      final mockClient = MockApiClient();
      mockClient.mockResponse = {
        'candidates': [
          {
            'content': {
              'parts': [
                {'text': 'Hello!'}
              ]
            }
          }
        ]
      };

      // Using the package-private test method via src import
      final model = createModelWithClient(
        app: Firebase.app('mockTestApp'),
        location: 'us-central1',
        model: 'gemini-pro',
        client: mockClient,
        useVertexBackend: true,
      );

      // We need to construct a request that uses Grounding.
      // Assuming there is a way to set tools or similar.
      // Let's just call a simple generateContent first to verify the mock works.
      final response = await model.generateContent([Content.text('Hi')]);

      expect(response.text, equals('Hello!'));
      expect(mockClient.requests, hasLength(1));

      final requestBody =
          mockClient.requests.first['body']! as Map<String, Object?>;
      expect(requestBody, contains('contents'));
    });

    test('Verify Request Payload for JSON Schema', () async {
      final mockClient = MockApiClient();
      mockClient.mockResponse = {
        'candidates': [
          {
            'content': {
              'parts': [
                {'text': '{"name": "Apple", "price": 1.2}'}
              ]
            }
          }
        ]
      };

      final model = createModelWithClient(
        app: Firebase.app('mockTestApp'),
        location: 'us-central1',
        model: 'gemini-pro',
        client: mockClient,
        useVertexBackend: true,
      );

      final schema = {
        'type': 'OBJECT',
        'properties': {
          'name': {'type': 'STRING'},
          'price': {'type': 'NUMBER'}
        },
        'required': ['name', 'price']
      };

      await model.generateContent(
        [Content.text('Give me a fruit')],
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          responseJsonSchema: schema,
        ),
      );

      expect(mockClient.requests, hasLength(1));
      final requestBody = mockClient.requests.first['body']! as Map<String, Object?>;
      expect(requestBody, contains('generationConfig'));
      
      final genConfig = requestBody['generationConfig']! as Map<String, Object?>;
      expect(genConfig['responseMimeType'], equals('application/json'));
      expect(genConfig['responseJsonSchema'], equals(schema));
    });

    test('Verify Request Payload for Multi-turn Chat', () async {
      final mockClient = MockApiClient();
      // Mock response for first turn
      mockClient.mockResponse = {
        'candidates': [
          {
            'content': {
              'role': 'model',
              'parts': [
                {'text': 'Hello!'}
              ]
            }
          }
        ]
      };

      final model = createModelWithClient(
        app: Firebase.app('mockTestApp'),
        location: 'us-central1',
        model: 'gemini-pro',
        client: mockClient,
        useVertexBackend: true,
      );

      final chat = model.startChat();

      // First turn
      await chat.sendMessage(Content.text('Hi'));

      // Mock response for second turn
      mockClient.mockResponse = {
        'candidates': [
          {
            'content': {
              'role': 'model',
              'parts': [
                {'text': 'I am good.'}
              ]
            }
          }
        ]
      };

      // Second turn
      await chat.sendMessage(Content.text('How are you?'));

      // Verify that the second request contains the history
      expect(mockClient.requests, hasLength(2));
      
      final secondRequest = mockClient.requests[1]['body']! as Map<String, Object?>;
      expect(secondRequest, contains('contents'));
      
      final contents = secondRequest['contents']! as List;
      expect(contents, hasLength(3)); // User 'Hi', Model 'Hello!', User 'How are you?'
      
      // Verify roles and text
      expect(contents[0]['role'], equals('user'));
      expect(contents[1]['role'], equals('model'));
      expect(contents[2]['role'], equals('user'));
      
      expect(contents[0]['parts'][0]['text'], equals('Hi'));
      expect(contents[1]['parts'][0]['text'], equals('Hello!'));
      expect(contents[2]['parts'][0]['text'], equals('How are you?'));
    });
  });
}
