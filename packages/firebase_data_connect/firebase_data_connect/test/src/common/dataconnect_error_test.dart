// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_data_connect/src/common/common_library.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DataConnectErrorCode', () {
    test('should have the correct enum values', () {
      expect(DataConnectErrorCode.unavailable.toString(),
          'DataConnectErrorCode.unavailable');
      expect(DataConnectErrorCode.unauthorized.toString(),
          'DataConnectErrorCode.unauthorized');
      expect(
          DataConnectErrorCode.other.toString(), 'DataConnectErrorCode.other');
    });
  });

  group('DataConnectError', () {
    test('should initialize with correct error code and message', () {
      final error = DataConnectError(
          DataConnectErrorCode.unavailable, 'Service is unavailable');

      expect(error.dataConnectErrorCode, DataConnectErrorCode.unavailable);
      expect(error.plugin, 'Data Connect');
      expect(error.code, 'DataConnectErrorCode.unavailable');
      expect(error.message, 'Service is unavailable');
    });

    test('should handle different error codes properly', () {
      final unauthorizedError = DataConnectError(
          DataConnectErrorCode.unauthorized, 'Unauthorized access');
      final otherError = DataConnectError(
          DataConnectErrorCode.other, 'Unknown error occurred');

      expect(unauthorizedError.dataConnectErrorCode,
          DataConnectErrorCode.unauthorized);
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

      expect(serializedString, "{key1: value1, key2: 123}");
    });

    test('should deserialize string data into expected format', () {
      Deserializer<Map<String, dynamic>> deserializer =
          (String data) => {'data': data};

      final inputData = '{"message": "Hello World"}';
      final deserializedData = deserializer(inputData);

      expect(deserializedData, {'data': '{"message": "Hello World"}'});
    });
  });
}
