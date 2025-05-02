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

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:firebase_data_connect/src/common/common_library.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'dart:io' show Platform;

// Mock classes for Firebase dependencies

class MockFirebaseAppCheck extends Mock implements FirebaseAppCheck {}

void main() {
  group('GoogApiClient', () {
    test('should return no codegen suffix if using core sdk', () {
      const packageVersion = '1.0.0';
      expect(
        getGoogApiVal(CallerSDKType.core, packageVersion),
        'gl-dart/$packageVersion fire/$packageVersion gl-${Platform.operatingSystem}',
      );
    });
    test('should return codegen suffix if using gen sdk', () {
      const packageVersion = '1.0.0';
      expect(
        getGoogApiVal(CallerSDKType.generated, packageVersion),
        'gl-dart/$packageVersion fire/$packageVersion dart/gen gl-${Platform.operatingSystem}',
      );
    });
  });
  group('TransportOptions', () {
    test('should properly initialize with given parameters', () {
      final transportOptions = TransportOptions('localhost', 8080, true);

      expect(transportOptions.host, 'localhost');
      expect(transportOptions.port, 8080);
      expect(transportOptions.isSecure, true);
    });

    test('should allow null values for optional parameters', () {
      final transportOptions = TransportOptions('localhost', null, null);

      expect(transportOptions.host, 'localhost');
      expect(transportOptions.port, null);
      expect(transportOptions.isSecure, null);
    });

    test('should update properties correctly', () {
      final transportOptions = TransportOptions('localhost', 8080, true);

      transportOptions.host = 'newhost';
      transportOptions.port = 9090;
      transportOptions.isSecure = false;

      expect(transportOptions.host, 'newhost');
      expect(transportOptions.port, 9090);
      expect(transportOptions.isSecure, false);
    });
  });

  group('DataConnectTransport', () {
    late DataConnectTransport transport;
    late TransportOptions transportOptions;
    late DataConnectOptions dataConnectOptions;
    late MockFirebaseAppCheck mockFirebaseAppCheck;

    setUp(() {
      transportOptions = TransportOptions('localhost', 8080, true);
      dataConnectOptions = DataConnectOptions(
        'projectId',
        'location',
        'connector',
        'serviceId',
      );
      mockFirebaseAppCheck = MockFirebaseAppCheck();

      transport = TestDataConnectTransport(
        transportOptions,
        dataConnectOptions,
        'testAppId',
        CallerSDKType.core,
        appCheck: mockFirebaseAppCheck,
      );
    });

    test('should properly initialize with given parameters', () {
      expect(transport.transportOptions.host, 'localhost');
      expect(transport.transportOptions.port, 8080);
      expect(transport.transportOptions.isSecure, true);
    });

    test('should handle invokeQuery with proper deserializer', () async {
      const queryName = 'testQuery';
      final deserializer = (json) => json;
      final result = await transport.invokeQuery(
        queryName,
        deserializer,
        emptySerializer,
        null,
        null,
      );

      expect(result, isNotNull);
    });

    test('should handle invokeMutation with proper deserializer', () async {
      const queryName = 'testMutation';
      final deserializer = (json) => json;
      final result = await transport.invokeMutation(
        queryName,
        deserializer,
        emptySerializer,
        null,
        null,
      );

      expect(result, isNotNull);
    });
  });
}

// Test class extending DataConnectTransport for testing purposes
class TestDataConnectTransport extends DataConnectTransport {
  TestDataConnectTransport(
    TransportOptions transportOptions,
    DataConnectOptions options,
    String appId,
    CallerSDKType sdkType, {
    FirebaseAppCheck? appCheck,
  }) : super(transportOptions, options, appId, sdkType) {
    this.appCheck = appCheck;
  }

  @override
  Future<Data> invokeQuery<Data, Variables>(
    String queryName,
    Deserializer<Data> deserializer,
    Serializer<Variables>? serializer,
    Variables? vars,
    String? authToken,
  ) async {
    // Simulate query invocation logic here
    return deserializer('{}');
  }

  @override
  Future<Data> invokeMutation<Data, Variables>(
    String queryName,
    Deserializer<Data> deserializer,
    Serializer<Variables>? serializer,
    Variables? vars,
    String? authToken,
  ) async {
    // Simulate mutation invocation logic here
    return deserializer('{}');
  }
}
