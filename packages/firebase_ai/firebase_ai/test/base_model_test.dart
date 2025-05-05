// Copyright 2025 Google LLC
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

import 'package:firebase_ai/src/base_model.dart';
import 'package:firebase_ai/src/client.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Mock FirebaseApp
// ignore: avoid_implementing_value_types
class MockFirebaseApp extends Mock implements FirebaseApp {
  @override
  FirebaseOptions get options => MockFirebaseOptions();

  @override
  bool get isAutomaticDataCollectionEnabled => true;
}

// Mock FirebaseOptions
// ignore: must_be_immutable, avoid_implementing_value_types
class MockFirebaseOptions extends Mock implements FirebaseOptions {
  @override
  String get projectId => 'test-project';

  @override
  String get appId => 'test-app-id';
}

// Mock Firebase App Check
class MockFirebaseAppCheck extends Mock implements FirebaseAppCheck {
  @override
  Future<String?> getToken([bool? forceRefresh = false]) async =>
      super.noSuchMethod(Invocation.method(#getToken, [forceRefresh]));
}

// Mock Firebase Auth
class MockFirebaseAuth extends Mock implements FirebaseAuth {
  @override
  User? get currentUser => super.noSuchMethod(Invocation.getter(#currentUser));
}

// Mock Firebase User
class MockUser extends Mock implements User {
  @override
  Future<String?> getIdToken([bool? forceRefresh = false]) async =>
      super.noSuchMethod(Invocation.method(#getIdToken, [forceRefresh]));
}

class MockApiClient extends Mock implements ApiClient {
  @override
  Future<Map<String, Object?>> makeRequest(
      Uri uri, Map<String, Object?> params) async {
    // Simulate a successful API response
    return {'mockResponse': 'success'};
  }
}

void main() {
  group('BaseModel', () {
    test('firebaseTokens returns a function that generates headers', () async {
      final tokenFunction = BaseModel.firebaseTokens(null, null, null);
      final headers = await tokenFunction();
      expect(headers['x-goog-api-client'], contains('gl-dart'));
      expect(headers['x-goog-api-client'], contains('fire'));
      expect(headers.length, 1);
    });

    test('firebaseTokens includes App Check token if available', () async {
      final mockAppCheck = MockFirebaseAppCheck();
      when(mockAppCheck.getToken())
          .thenAnswer((_) async => 'test-app-check-token');
      final tokenFunction = BaseModel.firebaseTokens(mockAppCheck, null, null);
      final headers = await tokenFunction();
      expect(headers['X-Firebase-AppCheck'], 'test-app-check-token');
      expect(headers['x-goog-api-client'], contains('gl-dart'));
      expect(headers['x-goog-api-client'], contains('fire'));
      expect(headers.length, 2);
    });

    test('firebaseTokens includes Auth ID token if available', () async {
      final mockAuth = MockFirebaseAuth();
      final mockUser = MockUser();
      when(mockUser.getIdToken()).thenAnswer((_) async => 'test-id-token');
      when(mockAuth.currentUser).thenReturn(mockUser);
      final tokenFunction = BaseModel.firebaseTokens(null, mockAuth, null);
      final headers = await tokenFunction();
      expect(headers['Authorization'], 'Firebase test-id-token');
      expect(headers['x-goog-api-client'], contains('gl-dart'));
      expect(headers['x-goog-api-client'], contains('fire'));
      expect(headers.length, 2);
    });

    test(
        'firebaseTokens includes App ID if automatic data collection is enabled',
        () async {
      final mockApp = MockFirebaseApp();

      final tokenFunction = BaseModel.firebaseTokens(null, null, mockApp);
      final headers = await tokenFunction();
      expect(headers['X-Firebase-AppId'], 'test-app-id');
      expect(headers['x-goog-api-client'], contains('gl-dart'));
      expect(headers['x-goog-api-client'], contains('fire'));
      expect(headers.length, 2);
    });

    test('firebaseTokens includes all tokens if available', () async {
      final mockAppCheck = MockFirebaseAppCheck();
      when(mockAppCheck.getToken())
          .thenAnswer((_) async => 'test-app-check-token');
      final mockAuth = MockFirebaseAuth();
      final mockUser = MockUser();
      when(mockUser.getIdToken()).thenAnswer((_) async => 'test-id-token');
      when(mockAuth.currentUser).thenReturn(mockUser);
      final mockApp = MockFirebaseApp();

      final tokenFunction =
          BaseModel.firebaseTokens(mockAppCheck, mockAuth, mockApp);
      final headers = await tokenFunction();
      expect(headers['X-Firebase-AppCheck'], 'test-app-check-token');
      expect(headers['Authorization'], 'Firebase test-id-token');
      expect(headers['X-Firebase-AppId'], 'test-app-id');
      expect(headers['x-goog-api-client'], contains('gl-dart'));
      expect(headers['x-goog-api-client'], contains('fire'));
      expect(headers.length, 4);
    });
  });
}
