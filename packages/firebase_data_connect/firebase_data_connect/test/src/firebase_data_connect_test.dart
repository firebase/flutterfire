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

class MockFirebaseAuth extends Mock implements FirebaseAuth {
  @override
  Stream<User?> idTokenChanges() {
    return super.noSuchMethod(
      Invocation.method(#idTokenChanges, []),
      returnValue: const Stream<User?>.empty(),
      returnValueForMissingStub: const Stream<User?>.empty(),
    ) as Stream<User?>;
  }
}

class MockFirebaseAppCheck extends Mock implements FirebaseAppCheck {}

class DynamicMockFirebaseApp extends Mock implements FirebaseApp {
  DynamicMockFirebaseApp({
    required this.name,
    required this.options,
    this.mockAuth,
    this.mockAppCheck,
  });

  @override
  final String name;

  @override
  final FirebaseOptions options;

  final FirebaseAuth? mockAuth;
  final FirebaseAppCheck? mockAppCheck;

  final Map<Type, FirebaseService> _registered = {};

  @override
  void registerService<T extends FirebaseService>(
    T service, {
    Future<void> Function(T service)? dispose,
  }) {
    _registered[T] = service;
  }

  @override
  T? getService<T extends FirebaseService>() {
    final registered = _registered[T];
    if (registered != null) {
      return registered as T;
    }
    if (T == FirebaseAppCheck) {
      return mockAppCheck as T?;
    }
    if (T == FirebaseAuth) {
      return mockAuth as T?;
    }
    return null;
  }
}

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
      );

      expect(dataConnect.app, equals(mockApp));
      expect(dataConnect.auth, isNull);
      expect(dataConnect.appCheck, isNull);
      expect(dataConnect.connectorConfig, equals(mockConnectorConfig));
      expect(dataConnect.options.projectId, 'fake_project_id');
    });

    test('checkTransport initializes transport correctly', () {
      final dataConnect = FirebaseDataConnect(
        app: mockApp,
        connectorConfig: mockConnectorConfig,
      );

      dataConnect.checkTransport();

      expect(dataConnect.transport, isNotNull);
    });

    test('query method returns QueryRef', () {
      final dataConnect = FirebaseDataConnect(
        app: mockApp,
        connectorConfig: mockConnectorConfig,
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
      );

      dataConnect.useDataConnectEmulator('localhost', 8080);

      expect(dataConnect.transportOptions, isNotNull);
      expect(dataConnect.transportOptions!.host, '10.0.2.2');
      expect(dataConnect.transportOptions!.port, 8080);
    });

    test('instanceFor returns cached instance if available', () {
      FirebaseDataConnect.cachedInstances.clear(); // Clear cache first

      final dynamicApp = DynamicMockFirebaseApp(
        name: 'cachedApp',
        options: const FirebaseOptions(
          apiKey: 'fake_api_key',
          appId: 'fake_app_id',
          messagingSenderId: 'fake_messaging_sender_id',
          projectId: 'fake_project_id',
        ),
      );
      when(mockConnectorConfig.toJson()).thenReturn('connectorConfigStr');

      final dataConnect = FirebaseDataConnect(
        app: dynamicApp,
        connectorConfig: mockConnectorConfig,
      );

      FirebaseDataConnect.cachedInstances['cachedApp'] = {
        'connectorConfigStr': dataConnect,
      };

      final instance = FirebaseDataConnect.instanceFor(
        app: dynamicApp,
        connectorConfig: mockConnectorConfig,
      );

      expect(instance, equals(dataConnect));
    });

    test('instanceFor creates new instance if not cached', () {
      FirebaseDataConnect.cachedInstances.clear(); // Clear cache first

      final dynamicApp = DynamicMockFirebaseApp(
        name: 'newInstanceApp',
        options: const FirebaseOptions(
          apiKey: 'fake_api_key',
          appId: 'fake_app_id',
          messagingSenderId: 'fake_messaging_sender_id',
          projectId: 'fake_project_id',
        ),
      );
      when(mockConnectorConfig.toJson()).thenReturn('newInstanceConnector');

      final instance = FirebaseDataConnect.instanceFor(
        app: dynamicApp,
        connectorConfig: mockConnectorConfig,
      );

      expect(instance, isA<FirebaseDataConnect>());
      final cached = FirebaseDataConnect.cachedInstances['newInstanceApp']!;
      expect(cached['newInstanceConnector'], equals(instance));
    });

    test('instanceFor attaches auth and app check from the app', () {
      FirebaseDataConnect.cachedInstances.clear();

      final dynamicApp = DynamicMockFirebaseApp(
        name: 'attachApp',
        options: const FirebaseOptions(
          apiKey: 'fake_api_key',
          appId: 'fake_app_id',
          messagingSenderId: 'fake_messaging_sender_id',
          projectId: 'fake_project_id',
        ),
      );
      when(mockConnectorConfig.toJson()).thenReturn('attachConnector');
      expect(dynamicApp.getService<FirebaseAuth>(), isNull);
      expect(dynamicApp.getService<FirebaseAppCheck>(), isNull);

      final instance = FirebaseDataConnect.instanceFor(
        app: dynamicApp,
        connectorConfig: mockConnectorConfig,
      );

      expect(instance.auth, isA<FirebaseAuth>());
      expect(instance.appCheck, isA<FirebaseAppCheck>());
      expect(dynamicApp.getService<FirebaseAuth>(), same(instance.auth));
      expect(
        dynamicApp.getService<FirebaseAppCheck>(),
        same(instance.appCheck),
      );
    });

    test(
        'checkTransport resolves dynamic service instances from registry just-in-time',
        () {
      FirebaseDataConnect.cachedInstances.clear();

      final dynamicApp = DynamicMockFirebaseApp(
        name: 'transportAppName',
        options: const FirebaseOptions(
          apiKey: 'fake_api_key',
          appId: 'fake_app_id',
          messagingSenderId: 'fake_messaging_sender_id',
          projectId: 'fake_project_id',
        ),
        mockAuth: mockAuth,
        mockAppCheck: mockAppCheck,
      );

      final instance = FirebaseDataConnect(
        app: dynamicApp,
        connectorConfig: mockConnectorConfig,
      );

      instance.checkTransport();

      final dynamic routingTransport = instance.transport;
      expect(routingTransport.rest.appCheck, equals(mockAppCheck));
      expect(routingTransport.websocket.auth, equals(mockAuth));
      expect(routingTransport.websocket.appCheck, equals(mockAppCheck));
    });
  });
}
