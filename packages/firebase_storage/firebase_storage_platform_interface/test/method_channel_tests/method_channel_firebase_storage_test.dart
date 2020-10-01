// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:firebase_storage_platform_interface/firebase_storage_platform_interface.dart';
import 'package:firebase_storage_platform_interface/src/method_channel/method_channel_firebase_storage.dart';
import '../mock.dart';

void main() {
  setupFirebaseStorageMocks();

  FirebaseStoragePlatform storage;
  FirebaseApp app;
  FirebaseApp secondaryApp;

  String kBucket = 'foo';

  group('$MethodChannelFirebaseStorage', () {
    setUpAll(() async {
      app = await Firebase.initializeApp();
      secondaryApp = await Firebase.initializeApp(
        name: 'testApp',
        options: const FirebaseOptions(
          appId: '1:1234567890:ios:42424242424242',
          apiKey: '123',
          projectId: '123',
          messagingSenderId: '1234567890',
        ),
      );

      storage = MethodChannelFirebaseStorage(app: app);
    });

    group('constructor', () {
      test('should create an instance with no args', () {
        MethodChannelFirebaseStorage test =
            MethodChannelFirebaseStorage(app: app, bucket: kBucket);
        expect(test.app, equals(Firebase.app()));
      });

      test('create an instance with default app', () {
        MethodChannelFirebaseStorage test =
            MethodChannelFirebaseStorage(app: Firebase.app());
        expect(test.app, equals(Firebase.app()));
      });
      test('create an instance with a secondary app', () {
        MethodChannelFirebaseStorage test =
            MethodChannelFirebaseStorage(app: secondaryApp);
        expect(test.app, equals(secondaryApp));
      });

      test('allow multiple instances', () {
        MethodChannelFirebaseStorage test1 = MethodChannelFirebaseStorage();
        MethodChannelFirebaseStorage test2 =
            MethodChannelFirebaseStorage(app: secondaryApp);
        expect(test1.app, equals(Firebase.app()));
        expect(test2.app, equals(secondaryApp));
      });
    });

    test('instance', () {
      expect(MethodChannelFirebaseStorage.instance,
          isInstanceOf<MethodChannelFirebaseStorage>());
    });

    test('nextMethodChannelHandleId', () {
      final handleId = MethodChannelFirebaseStorage.nextMethodChannelHandleId;

      expect(
          MethodChannelFirebaseStorage.nextMethodChannelHandleId, handleId + 1);

      nextMockHandleId;
      nextMockHandleId;
    });

    test('taskObservers', () {
      expect(MethodChannelFirebaseStorage.taskObservers,
          isInstanceOf<Map<int, StreamController<TaskSnapshotPlatform>>>());
    });

    group('delegateFor()', () {
      test('returns a [FirebaseStoragePlatform] with arguments', () {
        final testStorage = TestMethodChannelFirebaseStorage(Firebase.app());
        final result = testStorage.delegateFor(app: Firebase.app());
        expect(result, isA<FirebaseStoragePlatform>());
        expect(result.app, isA<FirebaseApp>());
      });
    });

    group('ref', () {
      test('should return a [ReferencePlatform]', () {
        final result = storage.ref('foo.bar');
        expect(result, isInstanceOf<ReferencePlatform>());
      });
    });
  });
}

class TestMethodChannelFirebaseStorage extends MethodChannelFirebaseStorage {
  TestMethodChannelFirebaseStorage(FirebaseApp app) : super(app: app);
}
