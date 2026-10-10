// Copyright 2026 Google LLC
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

import 'package:firebase_data_connect/src/common/common_library.dart';
import 'package:firebase_data_connect/src/firebase_data_connect.dart';
import 'package:firebase_data_connect/src/network/rest_library.dart';
import 'package:firebase_data_connect/src/network/transport_library.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'routing_transport_test.mocks.dart';

@GenerateMocks([RestTransport, WebSocketTransport])
void main() {
  group('RoutingTransport', () {
    late MockRestTransport mockRest;
    late MockWebSocketTransport mockWS;
    late RoutingTransport routingTransport;

    setUp(() {
      mockRest = MockRestTransport();
      mockWS = MockWebSocketTransport();
      routingTransport = RoutingTransport(mockRest, mockWS);
    });

    group('invokeQuery', () {
      test('should route to WS when connected and has active subscriptions', () async {
        when(mockWS.isConnected).thenReturn(true);
        when(mockWS.hasActiveSubscriptions).thenReturn(true);
        final expectedResponse = ServerResponse({});
        when(mockWS.invokeQuery<dynamic, dynamic>(any, any, any, any, any, any))
            .thenAnswer((_) => Future.value(expectedResponse));

        final response = await routingTransport.invokeQuery(
          'opId',
          'queryName',
          (json) => json,
          null,
          null,
          'token',
        );

        expect(response, equals(expectedResponse));
        verify(mockWS.invokeQuery<dynamic, dynamic>(any, any, any, any, any, any)).called(1);
        verifyNever(mockRest.invokeQuery<dynamic, dynamic>(any, any, any, any, any, any));
      });

      test('should route to REST when connected but has NO active subscriptions', () async {
        when(mockWS.isConnected).thenReturn(true);
        when(mockWS.hasActiveSubscriptions).thenReturn(false);
        final expectedResponse = ServerResponse({});
        when(mockRest.invokeQuery<dynamic, dynamic>(any, any, any, any, any, any))
            .thenAnswer((_) => Future.value(expectedResponse));

        final response = await routingTransport.invokeQuery(
          'opId',
          'queryName',
          (json) => json,
          null,
          null,
          'token',
        );

        expect(response, equals(expectedResponse));
        verify(mockRest.invokeQuery<dynamic, dynamic>(any, any, any, any, any, any)).called(1);
        verifyNever(mockWS.invokeQuery<dynamic, dynamic>(any, any, any, any, any, any));
      });

      test('should route to REST when WS is NOT connected', () async {
        when(mockWS.isConnected).thenReturn(false);
        when(mockWS.hasActiveSubscriptions).thenReturn(false);
        final expectedResponse = ServerResponse({});
        when(mockRest.invokeQuery<dynamic, dynamic>(any, any, any, any, any, any))
            .thenAnswer((_) => Future.value(expectedResponse));

        final response = await routingTransport.invokeQuery(
          'opId',
          'queryName',
          (json) => json,
          null,
          null,
          'token',
        );

        expect(response, equals(expectedResponse));
        verify(mockRest.invokeQuery<dynamic, dynamic>(any, any, any, any, any, any)).called(1);
        verifyNever(mockWS.invokeQuery<dynamic, dynamic>(any, any, any, any, any, any));
      });
    });

    group('invokeMutation', () {
      test('should route to WS when connected and has active subscriptions', () async {
        when(mockWS.isConnected).thenReturn(true);
        when(mockWS.hasActiveSubscriptions).thenReturn(true);
        final expectedResponse = ServerResponse({});
        when(mockWS.invokeMutation<dynamic, dynamic>(any, any, any, any, any, any))
            .thenAnswer((_) => Future.value(expectedResponse));

        final response = await routingTransport.invokeMutation(
          'opId',
          'mutationName',
          (json) => json,
          null,
          null,
          'token',
        );

        expect(response, equals(expectedResponse));
        verify(mockWS.invokeMutation<dynamic, dynamic>(any, any, any, any, any, any)).called(1);
        verifyNever(mockRest.invokeMutation<dynamic, dynamic>(any, any, any, any, any, any));
      });

      test('should route to REST when connected but has NO active subscriptions', () async {
        when(mockWS.isConnected).thenReturn(true);
        when(mockWS.hasActiveSubscriptions).thenReturn(false);
        final expectedResponse = ServerResponse({});
        when(mockRest.invokeMutation<dynamic, dynamic>(any, any, any, any, any, any))
            .thenAnswer((_) => Future.value(expectedResponse));

        final response = await routingTransport.invokeMutation(
          'opId',
          'mutationName',
          (json) => json,
          null,
          null,
          'token',
        );

        expect(response, equals(expectedResponse));
        verify(mockRest.invokeMutation<dynamic, dynamic>(any, any, any, any, any, any)).called(1);
        verifyNever(mockWS.invokeMutation<dynamic, dynamic>(any, any, any, any, any, any));
      });

      test('should route to REST when WS is NOT connected', () async {
        when(mockWS.isConnected).thenReturn(false);
        when(mockWS.hasActiveSubscriptions).thenReturn(false);
        final expectedResponse = ServerResponse({});
        when(mockRest.invokeMutation<dynamic, dynamic>(any, any, any, any, any, any))
            .thenAnswer((_) => Future.value(expectedResponse));

        final response = await routingTransport.invokeMutation(
          'opId',
          'mutationName',
          (json) => json,
          null,
          null,
          'token',
        );

        expect(response, equals(expectedResponse));
        verify(mockRest.invokeMutation<dynamic, dynamic>(any, any, any, any, any, any)).called(1);
        verifyNever(mockWS.invokeMutation<dynamic, dynamic>(any, any, any, any, any, any));
      });
    });
  });
}
