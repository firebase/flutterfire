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

// ignore_for_file: unused_local_variable

import 'dart:async';
import 'package:http/http.dart' as http;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:firebase_data_connect/src/common/common_library.dart';
import 'package:firebase_data_connect/src/core/ref.dart';
import 'package:firebase_data_connect/src/network/rest_library.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../network/rest_transport_test.mocks.dart';

// Mock classes
class MockDataConnectTransport extends Mock implements DataConnectTransport {}

class MockFirebaseDataConnect extends Mock implements FirebaseDataConnect {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockQueryManager extends Mock implements QueryManager {}

class MockOperationRef extends Mock implements OperationRef {}

void main() {
  group('OperationResult', () {
    test('should initialize correctly with provided data and ref', () {
      const mockData = 'sampleData';
      final mockRef = MockOperationRef();
      final mockFirebaseDataConnect = MockFirebaseDataConnect();

      final result =
          OperationResult(mockFirebaseDataConnect, mockData, DataSource.server, mockRef);

      expect(result.data, mockData);
      expect(result.ref, mockRef);
      expect(result.dataConnect, mockFirebaseDataConnect);
    });
  });

  group('QueryResult', () {
    test('should initialize correctly and inherit from OperationResult', () {
      const mockData = 'sampleData';
      final mockRef = MockOperationRef();
      final mockFirebaseDataConnect = MockFirebaseDataConnect();

      final queryResult =
          QueryResult(mockFirebaseDataConnect, mockData, DataSource.server, mockRef);

      expect(queryResult.data, mockData);
      expect(queryResult.ref, mockRef);
      expect(queryResult.dataConnect, mockFirebaseDataConnect);
    });
  });

  group('_QueryManager', () {
    late MockFirebaseDataConnect mockDataConnect;
    late QueryManager queryManager;

    setUp(() {
      mockDataConnect = MockFirebaseDataConnect();
      queryManager = QueryManager(mockDataConnect);
    });

    test(
        'addQuery should create a new StreamController if query does not exist',
        () {
      final stream =
          queryManager.addQuery('testQuery', 'variables', 'varsAsStr');

      expect(queryManager.trackedQueries['testQuery'], isNotNull);
      expect(queryManager.trackedQueries['testQuery']!['varsAsStr'], isNotNull);
      expect(stream, isA<Stream>());
    });
  });

  group('MutationRef', () {
    late MockDataConnectTransport mockTransport;
    late MockFirebaseDataConnect mockDataConnect;
    late Serializer<String> serializer;
    late Deserializer<String> deserializer;

    setUp(() {
      mockTransport = MockDataConnectTransport();
      mockDataConnect = MockFirebaseDataConnect();
      serializer = (data) => 'serializedData';
      deserializer = (data) => 'deserializedData';
    });
  });
  group('QueryRef', () {
    late RestTransport transport;
    late MockFirebaseDataConnect mockDataConnect;
    late Serializer<String> serializer;
    late MockClient mockHttpClient;
    late Deserializer<String> deserializer;
    late MockFirebaseAuth auth;
    late MockUser mockUser;

    setUp(() {
      mockDataConnect = MockFirebaseDataConnect();
      auth = MockFirebaseAuth();
      mockUser = MockUser();
      when(mockDataConnect.auth).thenReturn(auth);
      when(auth.currentUser).thenReturn(mockUser);
      mockHttpClient = MockClient();
      transport = RestTransport(
        TransportOptions('testhost', 443, true),
        DataConnectOptions(
          'testProject',
          'testLocation',
          'testConnector',
          'testService',
        ),
        'testAppId',
        CallerSDKType.core,
        null,
      );
      transport.setHttp(mockHttpClient);
      mockDataConnect.transport = transport;
    });
    test('executeQuery should gracefully handle getIdToken failures', () async {
      final deserializer = (String data) => 'Deserialized Data';
      final mockResponseSuccess = http.Response('{"success": true}', 200);
      when(mockUser.getIdToken()).thenThrow(Exception('Auth error'));
      QueryRef ref = QueryRef(
        mockDataConnect,
        'operation',
        transport,
        deserializer,
        QueryManager(mockDataConnect),
        emptySerializer,
        null,
      );
      when(
        mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer((_) async => mockResponseSuccess);
      await ref.execute();
    });
    test(
        'query should forceRefresh on ID token if the first request is unauthorized',
        () async {
      final mockResponse = http.Response('{"error": "Unauthorized"}', 401);
      final mockResponseSuccess = http.Response('{"success": true}', 200);
      final deserializer = (String data) => 'Deserialized Data';
      int count = 0;
      int idTokenCount = 0;
      QueryRef ref = QueryRef(
        mockDataConnect,
        'operation',
        transport,
        deserializer,
        QueryManager(mockDataConnect),
        emptySerializer,
        null,
      );
      when(mockUser.getIdToken()).thenAnswer(
        (invocation) => [
          Future.value('invalid-token'),
          Future.value('valid-token'),
        ][idTokenCount++],
      );

      when(
        mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer(
        (invocation) => [
          Future.value(mockResponse),
          Future.value(mockResponseSuccess),
        ][count++],
      );
      final result = await ref.execute();

      expect(result.data, 'Deserialized Data');
      verify(
        mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).called(2);
    });
  });
}
