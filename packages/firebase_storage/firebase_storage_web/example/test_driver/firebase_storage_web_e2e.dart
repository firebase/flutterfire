// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:firebase_storage_web/src/firebase_storage_web.dart';
import 'package:mockito/mockito.dart';

import 'mocks/mocks.dart';

void runFirebaseStorageWebTests() {
  group('TaskWeb', () {
    FirebaseStorageWeb storage;

    MockFbStorage fbStorage;

    setUp(() {
      fbStorage = MockFbStorage();

      storage = FirebaseStorageWeb.forMock(
        app: FakeApp(),
        bucket: 'some-bucket',
        fbStorage: fbStorage,
      );
    });

    group('maxRetryTimes kept track by the plugin', () {
      test('maxDownloadRetryTime get/set', () {
        int defaultMaxDownloadRetryTime = Duration(minutes: 10).inMilliseconds;

        expect(storage.maxDownloadRetryTime, defaultMaxDownloadRetryTime);

        storage.setMaxDownloadRetryTime(1000);

        expect(storage.maxDownloadRetryTime, 1000);
      });

      test('maxOperationRetryTime get/set', () {
        int defaultMaxOperationRetryTime = Duration(minutes: 2).inMilliseconds;

        expect(storage.maxOperationRetryTime, defaultMaxOperationRetryTime);

        storage.setMaxOperationRetryTime(1000);

        verify(fbStorage.setMaxOperationRetryTime(1000));
      });
    });

    group('maxRetryTimes delegated to JS', () {
      final default_retry_time = 10000;

      setUp(() {
        when(fbStorage.maxOperationRetryTime).thenReturn(default_retry_time);
        when(fbStorage.maxUploadRetryTime).thenReturn(default_retry_time);
      });

      test('maxUploadRetryTime get/set', () {
        expect(storage.maxUploadRetryTime, default_retry_time);

        storage.setMaxUploadRetryTime(1000);

        verify(fbStorage.setMaxUploadRetryTime(1000));
      });
    });

    group('ref', () {
      test('ref created successfully', () {
        final fakeRef = FakeRef();
        final ReferenceBuilder refBuilder = (FirebaseStorageWeb s, String p) {
          expect(s, storage);
          expect(p, 'some-path');
          return fakeRef;
        };

        final reference = storage.ref('some-path', refBuilder: refBuilder);

        expect(reference, fakeRef);
      });

      test('ref throws FirebaseError', () {
        final ReferenceBuilder refBuilder = (FirebaseStorageWeb s, String p) {
          throw FakeFbError()
            ..code = 'storage/object-not-found'
            ..message = 'Something went wrong!';
        };

        try {
          storage.ref('some-path', refBuilder: refBuilder);
          fail('Should have thrown an exception');
        } catch (e) {
          expect(e, isA<FirebaseException>());
          expect((e as FirebaseException).code, 'object-not-found');
          expect((e as FirebaseException).message,
              'No object exists at the desired reference.');
        }
      });
    });
  });
}
