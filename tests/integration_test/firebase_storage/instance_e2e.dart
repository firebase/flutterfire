// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tests/firebase_options.dart';

import 'test_utils.dart';

void setupInstanceTests() {
  group('$FirebaseStorage', () {
    late FirebaseStorage storage;
    late FirebaseApp secondaryApp;
    late FirebaseApp secondaryAppWithoutBucket;

    setUpAll(() async {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      storage = FirebaseStorage.instance;
      secondaryApp = await testInitializeSecondaryApp();
    });

    test('instance', () {
      expect(storage, isA<FirebaseStorage>());
      expect(storage.app, isA<FirebaseApp>());
      expect(storage.app.name, defaultFirebaseAppName);
    });

    test('instanceFor', () {
      FirebaseStorage secondaryStorage =
          FirebaseStorage.instanceFor(app: secondaryApp, bucket: 'test');
      expect(storage.app, isA<FirebaseApp>());
      expect(secondaryStorage, isA<FirebaseStorage>());
      expect(secondaryStorage.app.name, 'testapp');
    });

    test('default bucket cannot be null', () async {
      try {
        secondaryAppWithoutBucket =
            await testInitializeSecondaryApp(withDefaultBucket: false);

        FirebaseStorage.instanceFor(
          app: secondaryAppWithoutBucket,
        );
        fail('should have thrown an error');
      } on FirebaseException catch (e) {
        expect(
          e.message,
          "No storage bucket could be found for the app 'testapp-no-bucket'. Ensure you have set the [storageBucket] on [FirebaseOptions] whilst initializing the secondary Firebase app.",
        );
      }
    });

    group('ref', () {
      test('uses default path if none provided', () {
        Reference ref = storage.ref();
        expect(ref.fullPath, '/');
      });

      test('accepts a custom path', () async {
        Reference ref = storage.ref('foo/bar/baz.png');
        expect(ref.fullPath, 'foo/bar/baz.png');
      });

      test('strips leading / from custom path', () async {
        Reference ref = storage.ref('/foo/bar/baz.png');
        expect(ref.fullPath, 'foo/bar/baz.png');
      });
    });

    group('refFromURL', () {
      test('accepts a gs url', () async {
        const url = 'gs://foo/bar/baz.png';
        Reference ref = storage.refFromURL(url);
        expect(ref.fullPath, 'bar/baz.png');
        expect(ref.bucket, 'foo');
      });

      test('accepts a https url from google cloud', () async {
        const url =
            'https://storage.googleapis.com/flutterfire-e2e-tests.appspot.com/pdf/4lqA70lYwfRgH1krOevw6mLMgPs2_162613790513241';
        Reference ref = storage.refFromURL(url);
        expect(ref.bucket, 'flutterfire-e2e-tests.appspot.com');
        expect(ref.name, '4lqA70lYwfRgH1krOevw6mLMgPs2_162613790513241');
        expect(
          ref.fullPath,
          'pdf/4lqA70lYwfRgH1krOevw6mLMgPs2_162613790513241',
        );
      });

      test('accepts a https url', () async {
        const url =
            'https://firebasestorage.googleapis.com/v0/b/flutterfire-e2e-tests.appspot.com/o/1mbTestFile.gif?alt=media';
        Reference ref = storage.refFromURL(url);
        expect(ref.bucket, 'flutterfire-e2e-tests.appspot.com');
        expect(ref.name, '1mbTestFile.gif');
        expect(ref.fullPath, '1mbTestFile.gif');
      });

      test('accepts a https url with a deep path', () async {
        const url =
            'https://firebasestorage.googleapis.com/v0/b/flutterfire-e2e-tests.appspot.com/o/nested/path/segments/1mbTestFile.gif?alt=media';
        Reference ref = storage.refFromURL(url);
        expect(ref.bucket, 'flutterfire-e2e-tests.appspot.com');
        expect(ref.name, '1mbTestFile.gif');
        expect(ref.fullPath, 'nested/path/segments/1mbTestFile.gif');
      });

      test('accepts a https url with special characters', () async {
        const url =
            'https://firebasestorage.googleapis.com/v0/b/flutterfire-e2e-tests.appspot.com/o/foo+bar/file with  spaces.png?alt=media';
        Reference ref = storage.refFromURL(url);
        expect(ref.bucket, 'flutterfire-e2e-tests.appspot.com');
        expect(ref.name, 'file with  spaces.png');
        expect(ref.fullPath, 'foo+bar/file with  spaces.png');
      });

      test('accepts a https encoded url', () async {
        const url =
            'https%3A%2F%2Ffirebasestorage.googleapis.com%2Fv0%2Fb%2Fflutterfire-e2e-tests.appspot.com%2Fo%2F1mbTestFile.gif%3Falt%3Dmedia';
        Reference ref = storage.refFromURL(url);
        expect(ref.bucket, 'flutterfire-e2e-tests.appspot.com');
        expect(ref.name, '1mbTestFile.gif');
        expect(ref.fullPath, '1mbTestFile.gif');
      });

      test('accepts a Storage emulator url', () {
        const url =
            'http://localhost:9199/v0/b/flutterfire-e2e-tests.appspot.com/o/1mbTestFile.gif?alt=media';
        Reference ref = storage.refFromURL(url);
        expect(ref.bucket, 'flutterfire-e2e-tests.appspot.com');
        expect(ref.name, '1mbTestFile.gif');
        expect(ref.fullPath, '1mbTestFile.gif');
      });

      test('accepts a https url including port number', () {
        const url =
            'https://firebasestorage.googleapis.com:433/v0/b/flutterfire-e2e-tests.appspot.com/o/nested/path/segments/1mbTestFile.gif?alt=media';
        Reference ref = storage.refFromURL(url);
        expect(ref.bucket, 'flutterfire-e2e-tests.appspot.com');
        expect(ref.name, '1mbTestFile.gif');
        expect(ref.fullPath, 'nested/path/segments/1mbTestFile.gif');

        const googleUrl =
            'https://storage.googleapis.com/flutterfire-e2e-tests.appspot.com/pdf/4lqA70lYwfRgH1krOevw6mLMgPs2_162613790513241';
        Reference refGoogle = storage.refFromURL(googleUrl);
        expect(refGoogle.bucket, 'flutterfire-e2e-tests.appspot.com');
        expect(refGoogle.name, '4lqA70lYwfRgH1krOevw6mLMgPs2_162613790513241');
        expect(
          refGoogle.fullPath,
          'pdf/4lqA70lYwfRgH1krOevw6mLMgPs2_162613790513241',
        );
      });

      test('throws an error if https url could not be parsed', () async {
        expect(
          () {
            storage.refFromURL('https://invertase.io');
            fail('Did not throw an Error.');
          },
          throwsA(
            isA<AssertionError>().having(
              (p0) => p0.message,
              'assertion message',
              contains(
                "url could not be parsed, ensure it's a valid storage url",
              ),
            ),
          ),
        );
      });

      test('accepts a gs url without a fullPath', () async {
        const url = 'gs://some-bucket';
        Reference ref = storage.refFromURL(url);
        expect(ref.bucket, url.replaceFirst('gs://', ''));
        expect(ref.fullPath, '/');
      });

      test('throws an error if url does not start with gs:// or https://',
          () async {
        expect(
          () {
            storage.refFromURL('bs://foo/bar/cat.gif');
            fail('Should have thrown an [AssertionError]');
          },
          throwsA(
            isA<AssertionError>().having(
              (p0) => p0.message,
              'assertion message',
              contains("a url must start with 'gs://' or 'https://'"),
            ),
          ),
        );
      });
    });

    group('setMaxOperationRetryTime', () {
      test('should set', () async {
        expect(
          storage.maxOperationRetryTime,
          const Duration(milliseconds: 120000),
        );
        storage.setMaxOperationRetryTime(const Duration(milliseconds: 100000));
        expect(
          storage.maxOperationRetryTime,
          const Duration(milliseconds: 100000),
        );
      });
    });

    group('setMaxUploadRetryTime', () {
      test('should set', () async {
        expect(
          storage.maxUploadRetryTime,
          const Duration(milliseconds: 600000),
        );
        storage.setMaxUploadRetryTime(const Duration(milliseconds: 120000));
        expect(
          storage.maxUploadRetryTime,
          const Duration(milliseconds: 120000),
        );
      });
    });

    group('setMaxDownloadRetryTime', () {
      test('should set', () async {
        expect(
          storage.maxDownloadRetryTime,
          const Duration(milliseconds: 600000),
        );
        storage.setMaxDownloadRetryTime(const Duration(milliseconds: 120000));
        expect(
          storage.maxDownloadRetryTime,
          const Duration(milliseconds: 120000),
        );
      });
    });

    test('toString', () {
      expect(
        storage.toString(),
        'FirebaseStorage(app: [DEFAULT], bucket: flutterfire-e2e-tests.appspot.com)',
      );
    });
  });
}
