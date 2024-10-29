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
import 'package:firebase_data_connect/src/common/common_library.dart';
import 'package:firebase_data_connect/src/generated/connector_service.pbgrpc.dart';
import 'package:firebase_data_connect/src/network/grpc_library.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'grpc_transport_test.mocks.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

@GenerateMocks([
  ClientChannel,
  FirebaseAppCheck,
  User,
  ConnectorServiceClient,
  ResponseFuture
])
void main() {
  late GRPCTransport transport;
  late MockFirebaseAuth mockAuth;
  late MockFirebaseAppCheck mockAppCheck;
  late MockUser mockUser;
  late MockConnectorServiceClient mockStub;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockAppCheck = MockFirebaseAppCheck();
    mockUser = MockUser();
    mockStub = MockConnectorServiceClient();

    when(mockAuth.currentUser).thenReturn(mockUser);

    transport = GRPCTransport(
      TransportOptions('testhost', 443, true),
      DataConnectOptions(
        'testProject',
        'testLocation',
        'testConnector',
        'testService',
      ),
      'testAppId',
      CallerSDKType.core,
      mockAppCheck,
    );

    transport.stub = mockStub;
  });

  group('GRPCTransport', () {
    test('should correctly initialize secure GRPC channel', () {
      expect(
        transport.channel.options.credentials,
        const ChannelCredentials.secure(),
      );
    });

    test('should correctly initialize insecure GRPC channel', () {
      final insecureTransport = GRPCTransport(
        TransportOptions('testhost', 443, false),
        DataConnectOptions(
          'testProject',
          'testLocation',
          'testConnector',
          'testService',
        ),
        'testAppId',
        CallerSDKType.core,
        mockAppCheck,
      );

      expect(
        insecureTransport.channel.options.credentials,
        const ChannelCredentials.insecure(),
      );
    });

    test('invokeQuery should throw an error on failed query execution',
        () async {
      when(mockStub.executeQuery(any, options: anyNamed('options')))
          .thenThrow(Exception('GRPC error'));

      final deserializer = (String data) => 'Deserialized Data';

      expect(
        () =>
            transport.invokeQuery('testQuery', deserializer, null, null, null),
        throwsA(isA<DataConnectError>()),
      );
    });

    test('invokeMutation should throw an error on failed mutation execution',
        () async {
      when(mockStub.executeMutation(any, options: anyNamed('options')))
          .thenThrow(Exception('GRPC error'));

      final deserializer = (String data) => 'Deserialized Data';

      expect(
        () => transport.invokeMutation(
            'testMutation', deserializer, null, null, null),
        throwsA(isA<DataConnectError>()),
      );
    });

    test('getMetadata should include auth and appCheck tokens in metadata',
        () async {
      when(mockUser.getIdToken()).thenAnswer((_) async => 'authToken123');
      when(mockAppCheck.getToken()).thenAnswer((_) async => 'appCheckToken123');

      final metadata = await transport.getMetadata('authToken123');

      expect(metadata['x-firebase-auth-token'], 'authToken123');
      expect(metadata['X-Firebase-AppCheck'], 'appCheckToken123');
    });

    test(
        'getMetadata should handle missing auth and appCheck tokens gracefully',
        () async {
      when(mockUser.getIdToken()).thenThrow(Exception('Auth error'));
      when(mockAppCheck.getToken()).thenThrow(Exception('AppCheck error'));

      final metadata = await transport.getMetadata(null);

      expect(metadata.containsKey('x-firebase-auth-token'), isFalse);
      expect(metadata.containsKey('X-Firebase-AppCheck'), isFalse);
    });
  });
}
