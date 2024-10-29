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

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:firebase_data_connect/src/common/common_library.dart';
import 'package:firebase_data_connect/src/core/ref.dart';
import 'package:firebase_data_connect/src/network/rest_library.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../network/rest_transport_test.mocks.dart';

class MockFirebaseDataConnect extends Mock implements FirebaseDataConnect {}

class DCMockUser extends Mock implements User {
  int count = 0;
  List<String?> tokens = ['invalid-token', 'valid-token'];
  @override
  Future<String?> getIdToken([bool forceRefresh = false]) {
    // First return an invalid token, then return a valid token
    return Future.value(tokens[count++]);
  }
}

class MockFirebaseAuth extends Mock implements FirebaseAuth {
  @override
  User? get currentUser => DCMockUser();
}

class MockQueryManager extends Mock implements QueryManager {}

class MockOperationRef extends Mock implements OperationRef {}

class MockQueryRef<Data, Variables> extends Mock
    implements QueryRef<Data, Variables> {}

class MockStreamController<T> extends Mock implements StreamController<T> {}

@GenerateMocks([
  DataConnectTransport,
])
void main() {
  group('OperationResult', () {
    test('should initialize correctly with provided data and ref', () {
      final mockData = 'sampleData';
      final mockRef = MockOperationRef();
      final mockFirebaseDataConnect = MockFirebaseDataConnect();

      final result =
          OperationResult(mockFirebaseDataConnect, mockData, mockRef);

      expect(result.data, mockData);
      expect(result.ref, mockRef);
      expect(result.dataConnect, mockFirebaseDataConnect);
    });
  });

  group('QueryResult', () {
    test('should initialize correctly and inherit from OperationResult', () {
      final mockData = 'sampleData';
      final mockRef = MockOperationRef();
      final mockFirebaseDataConnect = MockFirebaseDataConnect();

      final queryResult =
          QueryResult(mockFirebaseDataConnect, mockData, mockRef);

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

    test('addQuery should return existing StreamController if query exists',
        () {
      final stream1 =
          queryManager.addQuery('testQuery', 'variables', 'varsAsStr');
      final stream2 =
          queryManager.addQuery('testQuery', 'variables', 'varsAsStr');

      expect(stream1, stream2);
    });

    test(
      'subscribe should propagate errors via the stream',
      () async {
        final mockTransport = MockDataConnectTransport();
        final queryManager = QueryManager(mockDataConnect);
        final mockStreamController = MockStreamController<QueryResult>();
        final completer = Completer<void>();

        final streamController = StreamController<QueryResult>.broadcast();

        queryManager.trackedQueries['testQuery'] = {'': streamController};

        final queryRef = QueryRef(
          mockDataConnect,
          'testQuery',
          mockTransport,
          emptySerializer,
          queryManager,
          emptySerializer,
          null,
        );

        streamController.stream.listen(
          (event) {
            fail('Error was not propagated to the stream');
          },
          onError: (error) {
            expect(error, isA<Exception>());
            expect(error.toString(), contains('Test Error'));
            completer.complete();
          },
        );

        // Manually trigger the callback since subscribe is not working in unit tests
        // TODO(Lyokone): find a way of using subscribe in unit tests
        queryManager.triggerCallback(
            'testQuery', '', queryRef, null, Exception('Test Error'));

        await completer.future.timeout(Duration(seconds: 2), onTimeout: () {
          fail('Error was not propagated to the stream');
        });
      },
    );

    test(
      'should propagate data via the stream',
      () async {
        final mockTransport = MockDataConnectTransport();
        final queryManager = QueryManager(mockDataConnect);
        final mockStreamController = MockStreamController<QueryResult>();
        final completer = Completer<void>();

        when(mockTransport.invokeQuery('testQuery', any, any, null, null))
            .thenAnswer((_) async => 'Deserialized Data');

        final streamController = StreamController<QueryResult>.broadcast();

        queryManager.trackedQueries['testQuery'] = {'': streamController};

        final queryRef = QueryRef(
          mockDataConnect,
          'testQuery',
          mockTransport,
          emptySerializer,
          queryManager,
          emptySerializer,
          null,
        );

        streamController.stream.listen(
          (event) {
            expect(event.data, 'Deserialized Data');
            expect(event.ref, queryRef);
            expect(event.dataConnect, mockDataConnect);
            completer.complete();
          },
          onError: (error) {
            fail('Error was propagated to the stream');
          },
        );

        // Manually trigger the callback since subscribe is not working in unit tests
        // TODO(Lyokone): find a way of using subscribe in unit tests
        queryManager.triggerCallback(
            'testQuery', '', queryRef, 'Deserialized Data', null);

        await completer.future.timeout(Duration(seconds: 2), onTimeout: () {
          fail('Data was not propagated to the stream');
        });
      },
    );

    test(
      'execute should propagate error as string when server responds with error',
      () async {
        final mockTransport = MockDataConnectTransport();
        final queryManager = QueryManager(mockDataConnect);

        // Simulate server throwing an exception
        when(mockTransport.invokeQuery(any, any, any, any))
            .thenThrow(Exception('Server Error'));

        final queryRef = QueryRef<String, String>(
          mockDataConnect,
          'testQuery',
          mockTransport,
          emptySerializer,
          queryManager,
          emptySerializer,
          'variables',
        );

        try {
          await queryRef.execute();
          fail('Expected execute to throw an exception.');
        } catch (error) {
          expect(error, isA<Exception>());
          expect(error.toString(), contains('Server Error'));
        }
      },
    );
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

    setUp(() {
      mockDataConnect = MockFirebaseDataConnect();
      when(mockDataConnect.auth).thenReturn(MockFirebaseAuth());
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
    test(
        'query should forceRefresh on ID token if the first request is unauthorized',
        () async {
      final mockResponse = http.Response('{"error": "Unauthorized"}', 401);
      final mockResponseSuccess = http.Response('{"success": true}', 200);
      final deserializer = (String data) => 'Deserialized Data';
      int count = 0;
      QueryRef ref = QueryRef(mockDataConnect, 'operation', transport,
          deserializer, QueryManager(mockDataConnect), emptySerializer, null);

      when(mockHttpClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((invocation) => [
                Future.value(mockResponse),
                Future.value(mockResponseSuccess),
              ][count++]);
      final result = await ref.execute();

      expect(result.data, 'Deserialized Data');
      verify(mockHttpClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .called(2);
    });
  });
}
