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

import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DataConnectErrorCode', () {
    test('should have the correct enum values', () {
      expect(
        DataConnectErrorCode.unavailable.toString(),
        'DataConnectErrorCode.unavailable',
      );
      expect(
        DataConnectErrorCode.unauthorized.toString(),
        'DataConnectErrorCode.unauthorized',
      );
      expect(
        DataConnectErrorCode.other.toString(),
        'DataConnectErrorCode.other',
      );
    });
  });

  group('DataConnectError', () {
    test('should initialize with correct error code and message', () {
      final error = DataConnectError(
        DataConnectErrorCode.unavailable,
        'Service is unavailable',
      );

      expect(error.dataConnectErrorCode, DataConnectErrorCode.unavailable);
      expect(error.plugin, 'Data Connect');
      expect(error.code, 'DataConnectErrorCode.unavailable');
      expect(error.message, 'Service is unavailable');
    });

    test('should handle different error codes properly', () {
      final unauthorizedError = DataConnectError(
        DataConnectErrorCode.unauthorized,
        'Unauthorized access',
      );
      final otherError = DataConnectError(
        DataConnectErrorCode.other,
        'Unknown error occurred',
      );

      expect(
        unauthorizedError.dataConnectErrorCode,
        DataConnectErrorCode.unauthorized,
      );
      expect(unauthorizedError.plugin, 'Data Connect');
      expect(unauthorizedError.code, 'DataConnectErrorCode.unauthorized');
      expect(unauthorizedError.message, 'Unauthorized access');

      expect(otherError.dataConnectErrorCode, DataConnectErrorCode.other);
      expect(otherError.plugin, 'Data Connect');
      expect(otherError.code, 'DataConnectErrorCode.other');
      expect(otherError.message, 'Unknown error occurred');
    });

    test('should allow null message', () {
      final error = DataConnectError(DataConnectErrorCode.unavailable, null);

      expect(error.message, null);
    });
  });

  group('Serializer and Deserializer', () {
    test('should serialize variables into string format', () {
      Serializer<Map<String, dynamic>> serializer =
          (Map<String, dynamic> vars) => vars.toString();

      final inputVars = {'key1': 'value1', 'key2': 123};
      final serializedString = serializer(inputVars);

      expect(serializedString, '{key1: value1, key2: 123}');
    });

    test('should deserialize string data into expected format', () {
      Deserializer<Map<String, dynamic>> deserializer =
          (String data) => {'data': data};

      const inputData = '{"message": "Hello World"}';
      final deserializedData = deserializer(inputData);

      expect(deserializedData, {'data': '{"message": "Hello World"}'});
    });
  });
}
