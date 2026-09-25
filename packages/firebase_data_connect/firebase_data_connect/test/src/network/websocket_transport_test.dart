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

import 'dart:async';
import 'dart:io';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_data_connect/src/common/common_library.dart';
import 'package:firebase_data_connect/src/network/transport_library.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_async/fake_async.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'websocket_transport_test.mocks.dart';

@GenerateMocks([FirebaseAuth, User, FirebaseAppCheck, WebSocketChannel, WebSocketSink])
void main() {
  late WebSocketTransport transport;
  late MockFirebaseAuth mockAuth;
  late MockFirebaseAppCheck mockAppCheck;
  late MockUser mockUser1;
  late MockUser mockUser2;
  late StreamController<User?> authChangesController;
  late HttpServer localHttpServer;

  setUp(() async {
    mockAuth = MockFirebaseAuth();
    mockAppCheck = MockFirebaseAppCheck();
    mockUser1 = MockUser();
    mockUser2 = MockUser();
    authChangesController = StreamController<User?>.broadcast();
    addTearDown(() => authChangesController.close());

    when(mockUser1.uid).thenReturn('uid-1');
    when(mockUser2.uid).thenReturn('uid-2');
    when(mockAuth.currentUser).thenReturn(mockUser1);
    when(mockAuth.idTokenChanges())
        .thenAnswer((_) => authChangesController.stream);

    localHttpServer = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => localHttpServer.close(force: true));

    transport = WebSocketTransport(
      TransportOptions(
          localHttpServer.address.host, localHttpServer.port, false),
      DataConnectOptions(
        'testProject',
        'testLocation',
        'testConnector',
        'testService',
      ),
      'testAppId',
      CallerSDKType.core,
      mockAppCheck,
      mockAuth,
    );
    addTearDown(() => transport.disconnect());
  });

  group('WebSocketTransport Idle Reconnection Guard', () {
    test(
        'should not schedule or perform any reconnect on auth user switch if there are no active subscriptions',
        () async {
      // Emit initial user (uid-1)
      authChangesController.add(mockUser1);
      await Future.delayed(Duration.zero);

      // Emit different user (uid-2) to trigger a user switch reconnect scenario
      authChangesController.add(mockUser2);
      await Future.delayed(Duration.zero);

      // Wait for longer than the initial reconnect delay (1000ms)
      await Future.delayed(const Duration(milliseconds: 1500));

      // Verify that the transport never attempted to refresh the token
      // (which is the first step of a reconnect) since the client is idle.
      verifyNever(mockUser2.getIdToken());
      expect(transport.isConnected, isFalse);
    });
  });

  group('WebSocketTransport Connection Grace Period', () {
    late MockWebSocketChannel mockChannel;
    late MockWebSocketSink mockSink;
    late StreamController<dynamic> channelStreamController;
    late int connectCount;

    setUp(() {
      mockChannel = MockWebSocketChannel();
      mockSink = MockWebSocketSink();
      channelStreamController = StreamController<dynamic>.broadcast();
      connectCount = 0;

      when(mockChannel.sink).thenReturn(mockSink);
      when(mockChannel.stream).thenAnswer((_) => channelStreamController.stream);
      when(mockChannel.ready).thenAnswer((_) => Future.value());
      when(mockSink.close()).thenAnswer((_) => Future.value());
    });

    tearDown(() {
      channelStreamController.close();
    });

    WebSocketTransport createTransport() {
      return WebSocketTransport(
        TransportOptions('localhost', 8080, false),
        DataConnectOptions('proj', 'loc', 'conn', 'serv'),
        'appId',
        CallerSDKType.core,
        mockAppCheck,
        mockAuth,
        (uri) {
          connectCount++;
          return mockChannel;
        },
      );
    }

    test('should disconnect after 15 seconds of idleness', () {
      fakeAsync((async) {
        final t = createTransport();

        // 1. Establish connection by subscribing
        final stream = t.invokeStreamQuery('opId', 'query', (json) => json, null, null, 'token');
        final sub = stream.listen((_) {});

        // Allow connection to establish (microtasks)
        async.flushMicrotasks();
        expect(t.isConnected, isTrue);
        expect(connectCount, equals(1));

        // 2. Unsubscribe to become idle
        sub.cancel();
        async.flushMicrotasks();

        // Verify it is NOT disconnected immediately
        expect(t.isConnected, isTrue);
        verifyNever(mockSink.close());

        // 3. Wait 14 seconds (less than 15s timeout)
        async.elapse(const Duration(seconds: 14));
        expect(t.isConnected, isTrue);
        verifyNever(mockSink.close());

        // 4. Wait 1 more second (total 15s)
        async.elapse(const Duration(seconds: 1));
        // It should disconnect
        expect(t.isConnected, isFalse);
        verify(mockSink.close()).called(1);
      });
    });

    test('should reuse connection if re-subscribed within 15 seconds', () {
      fakeAsync((async) {
        final t = createTransport();

        // 1. Subscribe 1
        final stream1 = t.invokeStreamQuery('opId', 'query', (json) => json, null, null, 'token');
        final sub1 = stream1.listen((_) {});
        async.flushMicrotasks();
        expect(t.isConnected, isTrue);
        expect(connectCount, equals(1));

        // 2. Unsubscribe 1
        sub1.cancel();
        async.flushMicrotasks();

        // 3. Wait 10 seconds (less than 15s)
        async.elapse(const Duration(seconds: 10));
        expect(t.isConnected, isTrue);

        // 4. Subscribe 2
        final stream2 = t.invokeStreamQuery('opId', 'query', (json) => json, null, null, 'token');
        final sub2 = stream2.listen((_) {});
        async.flushMicrotasks();

        // Verify connection was reused (connectCount is still 1)
        expect(t.isConnected, isTrue);
        expect(connectCount, equals(1));

        // Cleanup
        sub2.cancel();
        async.elapse(const Duration(seconds: 15));
      });
    });

    test('should establish new connection if re-subscribed after 15 seconds', () {
      fakeAsync((async) {
        final t = createTransport();

        // 1. Subscribe 1
        final stream1 = t.invokeStreamQuery('opId', 'query', (json) => json, null, null, 'token');
        final sub1 = stream1.listen((_) {});
        async.flushMicrotasks();
        expect(t.isConnected, isTrue);
        expect(connectCount, equals(1));

        // 2. Unsubscribe 1
        sub1.cancel();
        async.flushMicrotasks();

        // 3. Wait 15 seconds -> should disconnect
        async.elapse(const Duration(seconds: 15));
        expect(t.isConnected, isFalse);
        verify(mockSink.close()).called(1);

        // 4. Subscribe 2
        final stream2 = t.invokeStreamQuery('opId', 'query', (json) => json, null, null, 'token');
        final sub2 = stream2.listen((_) {});
        async.flushMicrotasks();

        // Verify new connection was established (connectCount is 2)
        expect(t.isConnected, isTrue);
        expect(connectCount, equals(2));

        // Cleanup
        sub2.cancel();
        async.elapse(const Duration(seconds: 15));
      });
    });
  });

  group('WebSocketTransport URL Validation', () {
    test('should connect with the correct sticky URL path', () async {
      final pathCompleter = Completer<String>();
      localHttpServer.listen((HttpRequest request) async {
        pathCompleter.complete(request.uri.path);
        await request.response.close();
      });

      final stream = transport.invokeStreamQuery(
        'testOpId',
        'testQuery',
        (json) => json,
        null,
        null,
        null,
      );

      final subscription = stream.listen((_) {});
      final actualPath = await pathCompleter.future.timeout(
        const Duration(seconds: 3),
        onTimeout: () =>
            fail('Server did not receive connection request in time'),
      );
      await subscription.cancel();

      final expectedPath =
          '/ws/google.firebase.dataconnect.v1.ConnectorStreamService.Connect'
          '/testProject/locations/testLocation/services/testService';
      expect(actualPath, equals(expectedPath));
    });
  });
}
