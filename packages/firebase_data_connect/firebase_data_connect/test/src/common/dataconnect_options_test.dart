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

import 'package:firebase_data_connect/src/common/common_library.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ConnectorConfig', () {
    test('should initialize with correct parameters', () {
      final config = ConnectorConfig('us-central1', 'cloud-sql', 'service-123');

      expect(config.location, 'us-central1');
      expect(config.connector, 'cloud-sql');
      expect(config.serviceId, 'service-123');
    });

    test('should return correct JSON representation', () {
      final config = ConnectorConfig('us-central1', 'cloud-sql', 'service-123');

      final jsonResult = config.toJson();
      final expectedJson = jsonEncode({
        'location': 'us-central1',
        'connector': 'cloud-sql',
        'serviceId': 'service-123',
      });

      expect(jsonResult, expectedJson);
    });

    test('should handle empty string parameters in JSON', () {
      final config = ConnectorConfig('', '', '');

      final jsonResult = config.toJson();
      final expectedJson = jsonEncode({
        'location': '',
        'connector': '',
        'serviceId': '',
      });

      expect(jsonResult, expectedJson);
    });
  });

  group('DataConnectOptions', () {
    test(
        'should initialize with correct parameters and inherit from ConnectorConfig',
        () {
      final options = DataConnectOptions(
        'project-abc',
        'us-central1',
        'cloud-sql',
        'service-123',
      );

      // Test inherited fields from ConnectorConfig
      expect(options.location, 'us-central1');
      expect(options.connector, 'cloud-sql');
      expect(options.serviceId, 'service-123');

      // Test new field specific to DataConnectOptions
      expect(options.projectId, 'project-abc');
    });

    test(
        'should return correct JSON representation for DataConnectOptions via ConnectorConfig toJson',
        () {
      final options = DataConnectOptions(
        'project-abc',
        'us-central1',
        'cloud-sql',
        'service-123',
      );

      final jsonResult = options.toJson();
      final expectedJson = jsonEncode({
        'location': 'us-central1',
        'connector': 'cloud-sql',
        'serviceId': 'service-123',
      });

      // Even though DataConnectOptions has a new field, toJson only reflects fields in ConnectorConfig
      expect(jsonResult, expectedJson);
    });
  });
}
