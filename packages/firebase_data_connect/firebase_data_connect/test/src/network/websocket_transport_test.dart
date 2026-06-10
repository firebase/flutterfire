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

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_data_connect/src/common/common_library.dart';
import 'package:firebase_data_connect/src/network/transport_library.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'websocket_transport_test.mocks.dart';

@GenerateMocks([FirebaseAuth, User, FirebaseAppCheck])
void main() {
  late WebSocketTransport transport;
  late MockFirebaseAuth mockAuth;
  late MockFirebaseAppCheck mockAppCheck;
  late MockUser mockUser1;
  late MockUser mockUser2;
  late StreamController<User?> authChangesController;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockAppCheck = MockFirebaseAppCheck();
    mockUser1 = MockUser();
    mockUser2 = MockUser();
    authChangesController = StreamController<User?>.broadcast();

    when(mockUser1.uid).thenReturn('uid-1');
    when(mockUser2.uid).thenReturn('uid-2');
    when(mockAuth.currentUser).thenReturn(mockUser1);
    when(mockAuth.idTokenChanges())
        .thenAnswer((_) => authChangesController.stream);

    transport = WebSocketTransport(
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
      mockAuth,
    );
  });

  tearDown(() async {
    await authChangesController.close();
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
}
