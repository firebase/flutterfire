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
    late MockFirebaseAppCheck mockAppCheck;
    late MockTransportOptions mockTransportOptions;
    late MockDataConnectOptions mockDataConnectOptions;

    setUp(() {
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
        mockAppCheck,
      );

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
        mockAppCheck,
      );

      expect(
        () async => transportStub.invokeMutation(
          'queryName',
          (json) => json,
          null,
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
        mockAppCheck,
      );

      expect(
        () async => transportStub.invokeQuery(
          'queryName',
          (json) => json,
          null,
          null,
          null,
        ),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });
}
