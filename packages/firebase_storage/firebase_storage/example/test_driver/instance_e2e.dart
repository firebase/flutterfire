import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_utils.dart';

void runInstanceTests() {
  group('$FirebaseStorage', () {
    FirebaseStorage storage;
    FirebaseApp secondaryApp;
    FirebaseApp secondaryAppWithoutBucket;

    setUpAll(() async {
      await Firebase.initializeApp();
      storage = FirebaseStorage.instance;
      secondaryApp = await testInitializeSecondaryApp(withDefaultBucket: true);
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
        expect(e.message,
            "No storage bucket could be found for the app 'testapp-no-bucket'. Ensure you have set the [storageBucket] on [FirebaseOptions] whilst initializing the secondary Firebase app.");
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
        expect(ref.fullPath, "bar/baz.png");
        expect(ref.bucket, "foo");
      });

      test('accepts a https url', () async {
        const url =
            'https://firebasestorage.googleapis.com/v0/b/react-native-firebase-testing.appspot.com/o/1mbTestFile.gif?alt=media';
        Reference ref = storage.refFromURL(url);
        expect(ref.bucket, 'react-native-firebase-testing.appspot.com');
        expect(ref.name, '1mbTestFile.gif');
        expect(ref.fullPath, "1mbTestFile.gif");
      });

      test('accepts a https encoded url', () async {
        const url =
            'https%3A%2F%2Ffirebasestorage.googleapis.com%2Fv0%2Fb%2Freact-native-firebase-testing.appspot.com%2Fo%2F1mbTestFile.gif%3Falt%3Dmedia';
        Reference ref = storage.refFromURL(url);
        expect(ref.bucket, 'react-native-firebase-testing.appspot.com');
        expect(ref.name, '1mbTestFile.gif');
        expect(ref.fullPath, "1mbTestFile.gif");
      });

      test('throws an error if https url could not be parsed', () async {
        try {
          storage.refFromURL('https://invertase.io');
          fail('Did not throw an Error.');
        } catch (error) {
          expect(
              error.message,
              contains(
                  "url could not be parsed, ensure it's a valid storage url"));
          return;
        }
      });

      test('accepts a gs url without a fullPath', () async {
        const url = 'gs://some-bucket';
        Reference ref = storage.refFromURL(url);
        expect(ref.bucket, url.replaceFirst("gs://", ""));
        expect(ref.fullPath, "/");
      });

      test('throws an error if url does not start with gs:// or https://',
          () async {
        try {
          storage.refFromURL('bs://foo/bar/cat.gif');
          fail('Did not throw an Error.');
        } on AssertionError catch (error) {
          expect(error.message,
              contains("a url must start with 'gs://' or 'https://'"));
        }
      });
    });

    group('setMaxOperationRetryTime', () {
      test('should set', () async {
        expect(storage.maxOperationRetryTime, Duration(milliseconds: 120000));
        await storage.setMaxOperationRetryTime(Duration(milliseconds: 100000));
        expect(storage.maxOperationRetryTime, Duration(milliseconds: 100000));
      });
    });

    group('setMaxUploadRetryTime', () {
      test('should set', () async {
        expect(storage.maxUploadRetryTime, Duration(milliseconds: 600000));
        await storage.setMaxUploadRetryTime(Duration(milliseconds: 120000));
        expect(storage.maxUploadRetryTime, Duration(milliseconds: 120000));
      });
    });

    group('setMaxDownloadRetryTime', () {
      test('should set', () async {
        expect(storage.maxDownloadRetryTime, Duration(milliseconds: 600000));
        await storage.setMaxDownloadRetryTime(Duration(milliseconds: 120000));
        expect(storage.maxDownloadRetryTime, Duration(milliseconds: 120000));
      });
    });

    test('toString', () {
      expect(storage.toString(),
          'FirebaseStorage(app: [DEFAULT], bucket: react-native-firebase-testing.appspot.com)');
    });
  });
}
