// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: avoid_catching_errors

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage_platform_interface/firebase_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../mock.dart';

void main() {
  setupFirebaseStorageMocks();

  TestFirebaseStoragePlatform? firebaseStoragePlatform;
  FirebaseApp? app;
  FirebaseApp? secondaryApp;

  group('$FirebaseStoragePlatform()', () {
    setUpAll(() async {
      app = await Firebase.initializeApp();
      secondaryApp = await Firebase.initializeApp(
        name: 'testApp2',
        options: const FirebaseOptions(
          appId: '1:1234567890:ios:42424242424242',
          apiKey: '123',
          projectId: '123',
          messagingSenderId: '1234567890',
        ),
      );

      firebaseStoragePlatform = TestFirebaseStoragePlatform(app);

      handleMethodCall((call) async {
        switch (call.method) {
          default:
            return null;
        }
      });
    });

    test('Constructor', () {
      expect(firebaseStoragePlatform, isA<FirebaseStoragePlatform>());
      expect(firebaseStoragePlatform, isA<PlatformInterface>());
    });

    test('FirebaseStoragePlatform.instanceFor', () {
      final result = FirebaseStoragePlatform.instanceFor(app: app!, bucket: '');
      expect(result, isA<FirebaseStoragePlatform>());
      expect(result.maxOperationRetryTime, equals(120000));
      expect(result.maxDownloadRetryTime, equals(600000));
      expect(result.maxUploadRetryTime, equals(600000));
    });

    test('get.instance', () {
      expect(FirebaseStoragePlatform.instance, isA<FirebaseStoragePlatform>());
      expect(FirebaseStoragePlatform.instance.app.name,
          equals(defaultFirebaseAppName));
    });

    group('set.instance', () {
      test('sets the current instance', () {
        FirebaseStoragePlatform.instance =
            TestFirebaseStoragePlatform(secondaryApp);

        expect(
            FirebaseStoragePlatform.instance, isA<FirebaseStoragePlatform>());
        expect(FirebaseStoragePlatform.instance.app.name, equals('testApp2'));
      });
    });

    test('throws if .delegateFor', () {
      try {
        firebaseStoragePlatform!.testDelegateFor();
      } on UnimplementedError catch (e) {
        expect(e.message, equals('delegateFor() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if get.maxOperationRetryTime', () {
      try {
        firebaseStoragePlatform!.maxOperationRetryTime;
      } on UnimplementedError catch (e) {
        expect(
            e.message, equals('get.maxOperationRetryTime is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if get.maxUploadRetryTime', () {
      try {
        firebaseStoragePlatform!.maxUploadRetryTime;
      } on UnimplementedError catch (e) {
        expect(e.message, equals('get.maxUploadRetryTime is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if get.maxDownloadRetryTime', () {
      try {
        firebaseStoragePlatform!.maxDownloadRetryTime;
      } on UnimplementedError catch (e) {
        expect(
            e.message, equals('get.maxDownloadRetryTime is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if setMaxOperationRetryTime()', () {
      try {
        firebaseStoragePlatform!.setMaxOperationRetryTime(100);
      } on UnimplementedError catch (e) {
        expect(
            e.message, equals('setMaxOperationRetryTime() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if setMaxUploadRetryTime()', () {
      try {
        firebaseStoragePlatform!.setMaxUploadRetryTime(100);
      } on UnimplementedError catch (e) {
        expect(e.message, equals('setMaxUploadRetryTime() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if setMaxDownloadRetryTime()', () {
      try {
        firebaseStoragePlatform!.setMaxDownloadRetryTime(100);
      } on UnimplementedError catch (e) {
        expect(
            e.message, equals('setMaxDownloadRetryTime() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if ref()', () {
      try {
        firebaseStoragePlatform!.ref('/foo');
      } on UnimplementedError catch (e) {
        expect(e.message, equals('ref() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });
  });
}

class TestFirebaseStoragePlatform extends FirebaseStoragePlatform {
  TestFirebaseStoragePlatform(FirebaseApp? app)
      : super(appInstance: app, bucket: '');
  FirebaseStoragePlatform testDelegateFor({FirebaseApp? app}) {
    return delegateFor(app: Firebase.app(), bucket: '');
  }
}
