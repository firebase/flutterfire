// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:cloud_firestore_platform_interface/src/method_channel/method_channel_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'pigeon/test_api.dart';

class _MockFirebaseFirestoreHostApi extends Mock
    implements TestFirebaseFirestoreHostApi {
  final Completer<void> storeResultCalled = Completer<void>();
  final Completer<void> releaseStoreResult = Completer<void>();

  @override
  Future<String> transactionCreate(
    FirestorePigeonFirebaseApp app,
    int timeout,
    int maxAttempts,
  ) async {
    return 'transaction-id';
  }

  @override
  Future<void> transactionStoreResult(
    String transactionId,
    InternalTransactionResult resultType,
    List<InternalTransactionCommand?>? commands,
  ) async {
    storeResultCalled.complete();
    await releaseStoreResult.future;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();

  const transactionId = 'transaction-id';
  const channelName =
      'plugins.flutter.io/firebase_firestore/transaction/$transactionId';
  const codec = StandardMethodCodec(PigeonCodec());

  late TestDefaultBinaryMessenger messenger;
  late _MockFirebaseFirestoreHostApi hostApi;
  late Completer<void> eventChannelListened;
  late FirebaseApp app;

  setUpAll(() async {
    app = await Firebase.initializeApp(
      name: 'test-app',
      options: const FirebaseOptions(
        apiKey: 'api-key',
        appId: 'app-id',
        messagingSenderId: 'sender-id',
        projectId: 'project-id',
      ),
    );
  });

  setUp(() {
    messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    hostApi = _MockFirebaseFirestoreHostApi();
    eventChannelListened = Completer<void>();

    TestFirebaseFirestoreHostApi.setUp(hostApi);
    messenger.setMockMessageHandler(channelName, (ByteData? message) async {
      if (!eventChannelListened.isCompleted) {
        eventChannelListened.complete();
      }
      return codec.encodeSuccessEnvelope(null);
    });
  });

  tearDown(() {
    TestFirebaseFirestoreHostApi.setUp(null);
    messenger.setMockMessageHandler(channelName, null);
  });

  test('does not complete the transaction future twice when native reports an '
      'error while storing a failure', () async {
    final firestore = MethodChannelFirebaseFirestore(
      app: app,
      databaseId: '(default)',
    );

    final transactionFuture = firestore.runTransaction<void>(
      (_) => throw StateError('handler failed'),
    );

    await eventChannelListened.future;
    unawaited(
      messenger.handlePlatformMessage(
        channelName,
        codec.encodeSuccessEnvelope(<String, Object?>{'appName': 'test-app'}),
        (_) {},
      ),
    );
    await hostApi.storeResultCalled.future;

    unawaited(
      messenger.handlePlatformMessage(
        channelName,
        codec.encodeSuccessEnvelope(<String, Object?>{
          'error': <String, Object?>{
            'code': 'deadline-exceeded',
            'message': 'Transaction timed out',
          },
        }),
        (_) {},
      ),
    );

    await expectLater(
      transactionFuture,
      throwsA(
        isA<FirebaseException>().having(
          (error) => error.code,
          'code',
          'deadline-exceeded',
        ),
      ),
    );

    hostApi.releaseStoreResult.complete();
    await Future<void>.delayed(Duration.zero);
  });
}
