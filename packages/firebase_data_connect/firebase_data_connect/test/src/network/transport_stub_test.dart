// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:firebase_data_connect/src/network/transport_library.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Create mock classes for FirebaseAuth, FirebaseAppCheck, and other dependencies.
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockFirebaseAppCheck extends Mock implements FirebaseAppCheck {}

class MockTransportOptions extends Mock implements TransportOptions {}

class MockDataConnectOptions extends Mock implements DataConnectOptions {}

void main() {
  group('TransportStub', () {
    late MockFirebaseAuth mockAuth;
    late MockFirebaseAppCheck mockAppCheck;
    late MockTransportOptions mockTransportOptions;
    late MockDataConnectOptions mockDataConnectOptions;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockAppCheck = MockFirebaseAppCheck();
      mockTransportOptions = MockTransportOptions();
      mockDataConnectOptions = MockDataConnectOptions();
    });

    test('constructor initializes with correct parameters', () {
      final transportStub = TransportStub(
        mockTransportOptions,
        mockDataConnectOptions,
        'mockAppId',
        CallerSDKType.core,
        mockAuth,
        mockAppCheck,
      );

      expect(transportStub.auth, equals(mockAuth));
      expect(transportStub.appCheck, equals(mockAppCheck));
      expect(transportStub.transportOptions, equals(mockTransportOptions));
      expect(transportStub.options, equals(mockDataConnectOptions));
    });

    test('invokeMutation throws UnimplementedError', () async {
      final transportStub = TransportStub(
        mockTransportOptions,
        mockDataConnectOptions,
        'mockAppId',
        CallerSDKType.core,
        mockAuth,
        mockAppCheck,
      );

      expect(
        () async => await transportStub.invokeMutation(
          'queryName',
          (json) => json,
          null,
          null,
        ),
        throwsA(isA<UnimplementedError>()),
      );
    });

    test('invokeQuery throws UnimplementedError', () async {
      final transportStub = TransportStub(
        mockTransportOptions,
        mockDataConnectOptions,
        'mockAppId',
        CallerSDKType.core,
        mockAuth,
        mockAppCheck,
      );

      expect(
        () async => await transportStub.invokeQuery(
          'queryName',
          (json) => json,
          null,
          null,
        ),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });
}
