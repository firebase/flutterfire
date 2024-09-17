// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_data_connect/firebase_data_connect.dart';
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
      mockAuth,
      mockAppCheck,
    );

    transport.setHttp(mockHttpClient);
  });

  group('RestTransport', () {
    test('should correctly initialize URL with secure protocol', () {
      expect(
        transport.url,
        'https://testhost:443/v1alpha/projects/testProject/locations/testLocation/services/testService/connectors/testConnector',
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
        mockAuth,
        mockAppCheck,
      );

      expect(
        insecureTransport.url,
        'http://testhost:443/v1alpha/projects/testProject/locations/testLocation/services/testService/connectors/testConnector',
      );
    });

    test('invokeOperation should return deserialized data', () async {
      final mockResponse = http.Response('{"data": {"key": "value"}}', 200);
      when(mockHttpClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => mockResponse);

      final deserializer = (String data) => 'Deserialized Data';

      final result = await transport.invokeOperation(
        'testQuery',
        deserializer,
        null,
        null,
        'executeQuery',
      );

      expect(result, 'Deserialized Data');
    });

    test('invokeOperation should throw unauthorized error on 401 response',
        () async {
      final mockResponse = http.Response('Unauthorized', 401);
      when(mockHttpClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => mockResponse);

      final deserializer = (String data) => 'Deserialized Data';

      expect(
        () => transport.invokeOperation(
            'testQuery', deserializer, null, null, 'executeQuery'),
        throwsA(isA<DataConnectError>()),
      );
    });

    test('invokeOperation should throw other errors on non-200 responses',
        () async {
      final mockResponse = http.Response('{"message": "Some error"}', 500);
      when(mockHttpClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => mockResponse);

      final deserializer = (String data) => 'Deserialized Data';

      expect(
        () => transport.invokeOperation(
            'testQuery', deserializer, null, null, 'executeQuery'),
        throwsA(isA<DataConnectError>()),
      );
    });

    test('invokeQuery should call invokeOperation with correct endpoint',
        () async {
      final mockResponse = http.Response('{"data": {"key": "value"}}', 200);
      when(mockHttpClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => mockResponse);

      final deserializer = (String data) => 'Deserialized Data';

      await transport.invokeQuery('testQuery', deserializer, null, null);

      verify(mockHttpClient.post(
        any,
        headers: anyNamed('headers'),
        body: json.encode({
          'name':
              'projects/testProject/locations/testLocation/services/testService/connectors/testConnector',
          'operationName': 'testQuery'
        }),
      )).called(1);
    });

    test('invokeMutation should call invokeOperation with correct endpoint',
        () async {
      final mockResponse = http.Response('{"data": {"key": "value"}}', 200);
      when(mockHttpClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => mockResponse);

      final deserializer = (String data) => 'Deserialized Mutation Data';

      await transport.invokeMutation('testMutation', deserializer, null, null);

      verify(mockHttpClient.post(
        any,
        headers: anyNamed('headers'),
        body: json.encode({
          'name':
              'projects/testProject/locations/testLocation/services/testService/connectors/testConnector',
          'operationName': 'testMutation'
        }),
      )).called(1);
    });

    test('invokeOperation should include auth and appCheck tokens in headers',
        () async {
      final mockResponse = http.Response('{"data": {"key": "value"}}', 200);
      when(mockHttpClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => mockResponse);

      when(mockUser.getIdToken()).thenAnswer((_) async => 'authToken123');
      when(mockAppCheck.getToken()).thenAnswer((_) async => 'appCheckToken123');

      final deserializer = (String data) => 'Deserialized Data';

      await transport.invokeOperation(
          'testQuery', deserializer, null, null, 'executeQuery');

      verify(mockHttpClient.post(
        any,
        headers: argThat(
          containsPair('X-Firebase-Auth-Token', 'authToken123'),
          named: 'headers',
        ),
        body: anyNamed('body'),
      )).called(1);
    });

    test(
        'invokeOperation should handle missing auth and appCheck tokens gracefully',
        () async {
      final mockResponse = http.Response('{"data": {"key": "value"}}', 200);
      when(mockHttpClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => mockResponse);

      when(mockUser.getIdToken()).thenThrow(Exception('Auth error'));
      when(mockAppCheck.getToken()).thenThrow(Exception('AppCheck error'));

      final deserializer = (String data) => 'Deserialized Data';

      await transport.invokeOperation(
          'testQuery', deserializer, null, null, 'executeQuery');

      verify(mockHttpClient.post(
        any,
        headers: argThat(
          isNot(contains('X-Firebase-Auth-Token')),
          named: 'headers',
        ),
        body: anyNamed('body'),
      )).called(1);
    });
  });
}
