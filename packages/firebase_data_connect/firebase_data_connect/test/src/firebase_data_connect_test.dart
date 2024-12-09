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
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:firebase_data_connect/src/common/common_library.dart';
import 'package:firebase_data_connect/src/core/ref.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<FirebaseApp>(), MockSpec<ConnectorConfig>()])
import 'firebase_data_connect_test.mocks.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockFirebaseAppCheck extends Mock implements FirebaseAppCheck {}

class MockTransportOptions extends Mock implements TransportOptions {}

class MockDataConnectTransport extends Mock implements DataConnectTransport {}

class MockQueryManager extends Mock implements QueryManager {}

void main() {
  group('FirebaseDataConnect', () {
    late MockFirebaseApp mockApp;
    late MockFirebaseAuth mockAuth;
    late MockFirebaseAppCheck mockAppCheck;
    late MockConnectorConfig mockConnectorConfig;

    setUp(() {
      mockApp = MockFirebaseApp();
      mockAuth = MockFirebaseAuth();
      mockAppCheck = MockFirebaseAppCheck();
      mockConnectorConfig = MockConnectorConfig();

      when(mockApp.options).thenReturn(
        const FirebaseOptions(
          apiKey: 'fake_api_key',
          appId: 'fake_app_id',
          messagingSenderId: 'fake_messaging_sender_id',
          projectId: 'fake_project_id',
        ),
      );
      when(mockConnectorConfig.location).thenReturn('us-central1');
      when(mockConnectorConfig.connector).thenReturn('connector');
      when(mockConnectorConfig.serviceId).thenReturn('serviceId');
    });

    test('constructor initializes with correct parameters', () {
      final dataConnect = FirebaseDataConnect(
        app: mockApp,
        connectorConfig: mockConnectorConfig,
        auth: mockAuth,
        appCheck: mockAppCheck,
      );

      expect(dataConnect.app, equals(mockApp));
      expect(dataConnect.auth, equals(mockAuth));
      expect(dataConnect.appCheck, equals(mockAppCheck));
      expect(dataConnect.connectorConfig, equals(mockConnectorConfig));
      expect(dataConnect.options.projectId, 'fake_project_id');
    });

    test('checkTransport initializes transport correctly', () {
      final dataConnect = FirebaseDataConnect(
        app: mockApp,
        connectorConfig: mockConnectorConfig,
        auth: mockAuth,
        appCheck: mockAppCheck,
      );

      dataConnect.checkTransport();

      expect(dataConnect.transport, isNotNull);
    });

    test('query method returns QueryRef', () {
      final dataConnect = FirebaseDataConnect(
        app: mockApp,
        connectorConfig: mockConnectorConfig,
        auth: mockAuth,
        appCheck: mockAppCheck,
      );

      final queryRef = dataConnect.query(
        'operationName',
        (json) => json,
        (variables) => variables.toString(),
        null,
      );

      expect(queryRef, isA<QueryRef>());
    });

    test('mutation method returns MutationRef', () {
      final dataConnect = FirebaseDataConnect(
        app: mockApp,
        connectorConfig: mockConnectorConfig,
        auth: mockAuth,
        appCheck: mockAppCheck,
      );

      final mutationRef = dataConnect.mutation(
        'operationName',
        (json) => json,
        (variables) => variables.toString(),
        null,
      );

      expect(mutationRef, isA<MutationRef>());
    });

    test('useDataConnectEmulator sets correct transport options', () {
      final dataConnect = FirebaseDataConnect(
        app: mockApp,
        connectorConfig: mockConnectorConfig,
        auth: mockAuth,
        appCheck: mockAppCheck,
      );

      dataConnect.useDataConnectEmulator('localhost', 8080);

      expect(dataConnect.transportOptions, isNotNull);
      expect(dataConnect.transportOptions!.host, '10.0.2.2');
      expect(dataConnect.transportOptions!.port, 8080);
    });

    test('instanceFor returns cached instance if available', () {
      FirebaseDataConnect.cachedInstances.clear(); // Clear cache first

      when(mockApp.name).thenReturn('appName');
      when(mockConnectorConfig.toJson()).thenReturn('connectorConfigStr');

      final dataConnect = FirebaseDataConnect(
        app: mockApp,
        connectorConfig: mockConnectorConfig,
        auth: mockAuth,
        appCheck: mockAppCheck,
      );

      FirebaseDataConnect.cachedInstances['appName'] = {
        'connectorConfigStr': dataConnect,
      };

      final instance = FirebaseDataConnect.instanceFor(
        app: mockApp,
        connectorConfig: mockConnectorConfig,
        auth: mockAuth,
        appCheck: mockAppCheck,
      );

      expect(instance, equals(dataConnect));
    });

    test('instanceFor creates new instance if not cached', () {
      FirebaseDataConnect.cachedInstances.clear(); // Clear cache first

      when(mockApp.name).thenReturn('appName');
      when(mockConnectorConfig.toJson()).thenReturn('connectorConfigStr');

      final instance = FirebaseDataConnect.instanceFor(
        app: mockApp,
        connectorConfig: mockConnectorConfig,
        auth: mockAuth,
        appCheck: mockAppCheck,
      );

      expect(instance, isA<FirebaseDataConnect>());
      expect(
        FirebaseDataConnect.cachedInstances['appName']!['connectorConfigStr'],
        equals(instance),
      );
    });
  });
}
