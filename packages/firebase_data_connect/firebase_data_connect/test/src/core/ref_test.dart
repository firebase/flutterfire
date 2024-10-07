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

import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:firebase_data_connect/src/common/common_library.dart';
import 'package:firebase_data_connect/src/core/ref.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Mock classes
class MockDataConnectTransport extends Mock implements DataConnectTransport {}

class MockFirebaseDataConnect extends Mock implements FirebaseDataConnect {}

class MockQueryManager extends Mock implements QueryManager {}

class MockOperationRef extends Mock implements OperationRef {}

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
