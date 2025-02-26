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

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_data_connect/src/common/common_library.dart';
import 'package:firebase_data_connect/src/dataconnect_version.dart';
import 'package:firebase_data_connect/src/network/rest_library.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'rest_transport_test.mocks.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

@GenerateMocks([http.Client, User, FirebaseAppCheck])
void main() {
  late RestTransport transport;
  late MockClient mockHttpClient;
  late MockFirebaseAuth mockAuth;
  late MockFirebaseAppCheck mockAppCheck;
  late MockUser mockUser;

  setUp(() {
    mockHttpClient = MockClient();
    mockAuth = MockFirebaseAuth();
    mockAppCheck = MockFirebaseAppCheck();
    mockUser = MockUser();
    when(mockAuth.currentUser).thenReturn(mockUser);

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
      mockAppCheck,
    );

    transport.setHttp(mockHttpClient);
  });

  group('RestTransport', () {
    test('should correctly initialize URL with secure protocol', () {
      expect(
        transport.url,
        'https://testhost:443/v1beta/projects/testProject/locations/testLocation/services/testService/connectors/testConnector',
      );
    });

    test('should correctly initialize URL with insecure protocol', () {
      final insecureTransport = RestTransport(
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
        insecureTransport.url,
        'http://testhost:443/v1beta/projects/testProject/locations/testLocation/services/testService/connectors/testConnector',
      );
    });

    test('invokeOperation should return deserialized data', () async {
      final mockResponse = http.Response('{"data": {"key": "value"}}', 200);
      when(
        mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer((_) async => mockResponse);

      final deserializer = (String data) => 'Deserialized Data';

      final result = await transport.invokeOperation(
        'testQuery',
        'executeQuery',
        deserializer,
        null,
        null,
        null,
      );

      expect(result, 'Deserialized Data');
    });

    test('invokeOperation should throw unauthorized error on 401 response',
        () async {
      final mockResponse = http.Response('Unauthorized', 401);
      when(
        mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer((_) async => mockResponse);

      final deserializer = (String data) => 'Deserialized Data';

      expect(
        () => transport.invokeOperation(
          'testQuery',
          'executeQuery',
          deserializer,
          null,
          null,
          null,
        ),
        throwsA(isA<DataConnectError>()),
      );
    });

    test('invokeOperation should throw other errors on non-200 responses',
        () async {
      final mockResponse = http.Response('{"message": "Some error"}', 500);
      when(
        mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer((_) async => mockResponse);

      final deserializer = (String data) => 'Deserialized Data';

      expect(
        () => transport.invokeOperation(
          'testQuery',
          'executeQuery',
          deserializer,
          null,
          null,
          null,
        ),
        throwsA(isA<DataConnectError>()),
      );
    });

    test('invokeQuery should call invokeOperation with correct endpoint',
        () async {
      final mockResponse = http.Response('{"data": {"key": "value"}}', 200);
      when(
        mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer((_) async => mockResponse);

      final deserializer = (String data) => 'Deserialized Data';

      await transport.invokeQuery('testQuery', deserializer, null, null, null);

      verify(
        mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: json.encode({
            'name':
                'projects/testProject/locations/testLocation/services/testService/connectors/testConnector',
            'operationName': 'testQuery',
          }),
        ),
      ).called(1);
    });

    test('invokeMutation should call invokeOperation with correct endpoint',
        () async {
      final mockResponse = http.Response('{"data": {"key": "value"}}', 200);
      when(
        mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer((_) async => mockResponse);

      final deserializer = (String data) => 'Deserialized Mutation Data';

      await transport.invokeMutation(
        'testMutation',
        deserializer,
        null,
        null,
        null,
      );

      verify(
        mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: json.encode({
            'name':
                'projects/testProject/locations/testLocation/services/testService/connectors/testConnector',
            'operationName': 'testMutation',
          }),
        ),
      ).called(1);
    });

    test('invokeOperation should include auth tokens in headers', () async {
      final mockResponse = http.Response('{"data": {"key": "value"}}', 200);
      when(
        mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer((_) async => mockResponse);

      when(mockUser.getIdToken()).thenAnswer((_) async => 'authToken123');
      when(mockAppCheck.getToken()).thenAnswer((_) async => 'appCheckToken123');

      final deserializer = (String data) => 'Deserialized Data';

      await transport.invokeOperation(
        'testQuery',
        'executeQuery',
        deserializer,
        null,
        null,
        'authToken123',
      );

      verify(
        mockHttpClient.post(
          any,
          headers: argThat(
            containsPair('X-Firebase-Auth-Token', 'authToken123'),
            named: 'headers',
          ),
          body: anyNamed('body'),
        ),
      ).called(1);
    });
    test('invokeOperation should include x-firebase-client headers', () async {
      final mockResponse = http.Response('{"data": {"key": "value"}}', 200);
      when(
        mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer((_) async => mockResponse);

      when(mockUser.getIdToken()).thenAnswer((_) async => 'authToken123');
      when(mockAppCheck.getToken()).thenAnswer((_) async => 'appCheckToken123');

      final deserializer = (String data) => 'Deserialized Data';

      await transport.invokeOperation(
        'testQuery',
        'executeQuery',
        deserializer,
        null,
        null,
        'authToken123',
      );

      verify(
        mockHttpClient.post(
          any,
          headers: argThat(
            containsPair(
                'x-firebase-client', getFirebaseClientVal(packageVersion)),
            named: 'headers',
          ),
          body: anyNamed('body'),
        ),
      ).called(1);
    });

    test('invokeOperation should include appcheck tokens in headers', () async {
      final mockResponse = http.Response('{"data": {"key": "value"}}', 200);
      when(mockHttpClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => mockResponse);

      when(mockUser.getIdToken()).thenAnswer((_) async => 'authToken123');
      when(mockAppCheck.getToken()).thenAnswer((_) async => 'appCheckToken123');

      final deserializer = (String data) => 'Deserialized Data';

      await transport.invokeOperation('testQuery', 'testEndpoint', deserializer,
          null, null, 'executeQuery');

      verify(mockHttpClient.post(
        any,
        headers: argThat(
          containsPair('X-Firebase-AppCheck', 'appCheckToken123'),
          named: 'headers',
        ),
        body: anyNamed('body'),
      )).called(1);
    });

    test(
        'invokeOperation should handle missing auth and appCheck tokens gracefully',
        () async {
      final mockResponse = http.Response('{"data": {"key": "value"}}', 200);
      when(
        mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer((_) async => mockResponse);

      when(mockUser.getIdToken()).thenThrow(Exception('Auth error'));
      when(mockAppCheck.getToken()).thenThrow(Exception('AppCheck error'));

      final deserializer = (String data) => 'Deserialized Data';

      await transport.invokeOperation(
        'testQuery',
        'executeQuery',
        deserializer,
        null,
        null,
        null,
      );

      verify(
        mockHttpClient.post(
          any,
          headers: argThat(
            isNot(contains('X-Firebase-Auth-Token')),
            named: 'headers',
          ),
          body: anyNamed('body'),
        ),
      ).called(1);
    });

    test('invokeOperation should throw an error if the server throws one',
        () async {
      final mockResponse = http.Response(
        '''
{
    "data": {},
    "errors": [
        {
            "message": "SQL query error: pq: duplicate key value violates unique constraint movie_pkey",
            "locations": [],
            "path": [
                "the_matrix"
            ],
            "extensions": null
        }
    ]
}''',
        200,
      );
      when(
        mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer((_) async => mockResponse);

      final deserializer = (String data) => 'Deserialized Data';

      expect(
        () => transport.invokeOperation(
          'testQuery',
          'executeQuery',
          deserializer,
          null,
          null,
          null,
        ),
        throwsA(isA<DataConnectError>()),
      );
    });
  });
}
