// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: unused_local_variable

import 'dart:async';

import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:firebase_data_connect/src/common/common_library.dart';
import 'package:firebase_data_connect/src/core/ref.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'ref_test.mocks.dart';

class MockFirebaseDataConnect extends Mock implements FirebaseDataConnect {}

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

        when(mockTransport.invokeQuery('testQuery', any, any, null))
            .thenThrow(Exception('Test Error'));

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

        when(mockTransport.invokeQuery('testQuery', any, any, null))
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
}
