// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage_platform_interface/firebase_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'mock.dart';

void main() {
  setupFirebaseStorageMocks();
  late FirebaseApp app;
  late FirebaseStorage storage;
  late FirebaseStorage storageSecondary;
  late FirebaseApp secondaryApp;

  group('$FirebaseStorage', () {
    setUpAll(() async {
      FirebaseStoragePlatform.instance = kMockStoragePlatform;

      app = await Firebase.initializeApp();

      storage = FirebaseStorage.instance;
      secondaryApp = await Firebase.initializeApp(
        name: 'foo',
        options: const FirebaseOptions(
          apiKey: '123',
          appId: '123',
          messagingSenderId: '123',
          projectId: '123',
          storageBucket: kSecondaryBucket,
        ),
      );
      storageSecondary = FirebaseStorage.instanceFor(app: secondaryApp);
    });

    test('instance', () async {
      expect(storage, isA<FirebaseStorage>());
      expect(storage, equals(FirebaseStorage.instance));
    });

    test('returns the correct $FirebaseApp', () {
      expect(storage.app, isA<FirebaseApp>());
    });

    group('instanceFor()', () {
      test('instance', () async {
        expect(storageSecondary.bucket,
            kSecondaryBucket.replaceFirst('gs://', ''));
        expect(storageSecondary.app.name, 'foo');
      });

      test('returns the correct $FirebaseApp', () {
        expect(storageSecondary.app, isA<FirebaseApp>());
        expect(storageSecondary.app.name, 'foo');
      });
    });

    group('get.maxOperationRetryTime', () {
      test('verify delegate method is called', () {
        const duration = Duration();
        expect(storage.maxOperationRetryTime, duration);
      });
    });

    group('get.maxUploadRetryTime', () {
      test('verify delegate method is called', () {
        const duration = Duration();
        expect(storage.maxUploadRetryTime, duration);
      });
    });

    group('get.maxDownloadRetryTime', () {
      test('verify delegate method is called', () {
        const duration = Duration();
        expect(storage.maxDownloadRetryTime, duration);
      });
    });

    // ref
    group('.ref()', () {
      test('accepts null', () {
        final reference = storage.ref();

        expect(reference, isA<Reference>());
        verify(kMockStoragePlatform.ref('/'));
      });

      test('accepts an empty string', () {
        const String testPath = '/';
        final reference = storage.ref('');

        expect(reference, isA<Reference>());
        verify(kMockStoragePlatform.ref(testPath));
      });

      test('accepts a specified path', () {
        const String testPath = '/foo';
        final reference = storage.ref(testPath);

        expect(reference, isA<Reference>());
        verify(kMockStoragePlatform.ref(testPath));
      });
    });

    group('.refFromURL()', () {
      test(
          "throws AssertionError when value does not start with 'gs://' or 'http'",
          () {
        expect(() => storage.refFromURL('invalid.com'), throwsAssertionError);
      });

      test('throws AssertionError when http url is not a valid storage url',
          () {
        const String url = 'https://test.com';
        expect(() => storage.refFromURL(url), throwsAssertionError);
      });

      test('verify delegate method is called for encoded http urls', () {
        const String customBucket = 'test.appspot.com';
        const String testPath = '1mbTestFile.gif';
        const String url =
            'https%3A%2F%2Ffirebasestorage.googleapis.com%2Fv0%2Fb%2F$customBucket%2Fo%2F$testPath%3Falt%3Dmedia';

        final ref = storage.refFromURL(url);

        expect(ref, isA<Reference>());
        verify(kMockStoragePlatform.ref(testPath));
      });

      test('verify delegate method is called for http urls with spaces', () {
        const String customBucket = 'test.appspot.com';
        const String testPath = 'file with  spaces   .gif';
        const String url =
            'https://firebasestorage.googleapis.com/v0/b/$customBucket/o/$testPath?alt=media';

        final ref = storage.refFromURL(url);

        expect(ref, isA<Reference>());
        verify(kMockStoragePlatform.ref(testPath));
      });

      // https://github.com/firebase/flutterfire/issues/5673
      test('verify delegate method is called for http urls with + symbol', () {
        const String customBucket = 'test.appspot.com';
        const String testPath = 'foo+bar/file.gif';
        const String url =
            'https://firebasestorage.googleapis.com/v0/b/$customBucket/o/$testPath?alt=media';

        final ref = storage.refFromURL(url);

        expect(ref, isA<Reference>());
        verify(kMockStoragePlatform.ref(testPath));
      });

      test("verify delegate method when url starts with 'gs://'", () {
        const String testPath = 'bar/baz.png';
        const String url = 'gs://foo/$testPath';

        final ref = storage.refFromURL(url);

        expect(ref, isA<Reference>());
        verify(kMockStoragePlatform.ref(testPath));
      });

      test('verify special characters are allowed in http path', () {
        const String customBucket = 'test.appspot.com';
        const String testPath = '[!@+= ^&*_+-= {};,.<> ].jpg';
        const String url =
            'https://firebasestorage.googleapis.com/v0/b/$customBucket/o/$testPath?alt=media';

        final ref = storage.refFromURL(url);

        expect(ref, isA<Reference>());
        verify(kMockStoragePlatform.ref(testPath));
      });
    });

    group('useStorageEmulator', () {
      test('throws AssertionError when host is empty', () {
        expect(() => storage.useStorageEmulator('', 123), throwsAssertionError);
      });

      test('throws AssertionError when port is negative', () {
        expect(
            () => storage.useStorageEmulator('foo', -10), throwsAssertionError);
      });

      test('verify delegate method is called with args', () {
        storage.useStorageEmulator('foo', 123);
        verify(kMockStoragePlatform.useStorageEmulator('foo', 123));
      });
    });

    group('setMaxDownloadRetryTime()', () {
      test('throws AssertionError if negative', () async {
        expect(
          () => storage.setMaxDownloadRetryTime(const Duration(seconds: -1)),
          throwsAssertionError,
        );
      });
    });

    group('setMaxOperationRetryTime()', () {
      test('throws AssertionError if negative', () async {
        expect(
          () => storage.setMaxOperationRetryTime(const Duration(seconds: -1)),
          throwsAssertionError,
        );
      });
    });

    group('setMaxUploadRetryTime()', () {
      test('throws AssertionError if 0', () async {
        expect(
          () => storage.setMaxUploadRetryTime(const Duration(seconds: -1)),
          throwsAssertionError,
        );
      });
    });

    group('hashCode()', () {
      test('returns the correct value', () {
        expect(
          storage.hashCode,
          Object.hash(app.name, kBucket.replaceFirst('gs://', '')),
        );
      });
    });

    group('toString()', () {
      test('returns the correct value', () {
        expect(
          storage.toString(),
          '$FirebaseStorage(app: ${app.name}, bucket: ${kBucket.replaceFirst("gs://", "")})',
        );
      });
    });
  });
}
