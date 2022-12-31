// Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import './test_utils.dart';

const secondStorageBucket = 'flutterfire-e2e-tests-two';
const allowableListsSecondBucket = 'allowable-lists-2nd-bucket';

void setupSecondBucketTests() {
  group('Second bucket', () {
    late FirebaseStorage storage;

    setUpAll(() async {
      storage = FirebaseStorage.instanceFor(
        app: Firebase.app(),
        bucket: secondStorageBucket,
      );
      if (defaultTargetPlatform != TargetPlatform.windows) {
        await storage.useStorageEmulator(testEmulatorHost, testEmulatorPort);
      }
      // Cannot putFile as it will fail on web e2e tests
      const string = 'some text for creating new files';
      final Reference ref = storage.ref('flutter-tests').child('flt-ok.txt');
      await ref.putString(string);

      //allowable-lists-2nd-bucket
      await storage
          .ref(allowableListsSecondBucket)
          .child('list-1.txt')
          .putString(string);
      await storage
          .ref(allowableListsSecondBucket)
          .child('list-2.txt')
          .putString(string);
      await storage
          .ref(allowableListsSecondBucket)
          .child('list-3.txt')
          .putString(string);
    });

    group('bucket', () {
      test('returns the storage bucket as a string', () async {
        expect(
          storage.ref('/ok.jpeg').bucket,
          secondStorageBucket,
        );
      });
    });

    group('fullPath', () {
      test('returns the full path as a string', () async {
        expect(
          storage.ref('/foo/uploadNope.jpeg').fullPath,
          'foo/uploadNope.jpeg',
        );

        expect(
          storage.ref('foo/uploadNope.jpeg').fullPath,
          'foo/uploadNope.jpeg',
        );
      });
    });

    group('name', () {
      test('returns the file name as a string', () async {
        Reference ref = storage.ref('/foo/uploadNope.jpeg');
        expect(ref.name, 'uploadNope.jpeg');
      });
    });

    group('parent', () {
      test('returns the parent directory as a reference', () async {
        expect(storage.ref('/foo/uploadNope.jpeg').parent?.fullPath, 'foo');
      });

      test('returns null if already at root', () async {
        Reference ref = storage.ref('/');
        expect(ref.parent, isNull);
      });
    });

    group('delete()', () {
      test('should delete a file', () async {
        Reference ref = storage.ref('flutter-tests/deleteMe.jpeg');
        await ref.putString('To Be Deleted :)');
        await ref.delete();

        await expectLater(
          () => ref.delete(),
          throwsA(
            isA<FirebaseException>()
                .having((e) => e.code, 'code', 'object-not-found')
                .having(
                  (e) => e.message,
                  'message',
                  'No object exists at the desired reference.',
                ),
          ),
        );
      });

      test('throws error if file does not exist', () async {
        Reference ref = storage.ref('flutter-tests/iDoNotExist.jpeg');

        await expectLater(
          () => ref.delete(),
          throwsA(
            isA<FirebaseException>()
                .having((e) => e.code, 'code', 'object-not-found')
                .having(
                  (e) => e.message,
                  'message',
                  'No object exists at the desired reference.',
                ),
          ),
        );
      });

      test('throws error if no write permission', () async {
        // second-bucket-not-allowed.jpeg is not allowed to be deleted via storage.rules for 2nd bucket
        Reference ref =
            storage.ref('flutter-tests/second-bucket-not-allowed.jpeg');

        await expectLater(
          () => ref.delete(),
          throwsA(
            isA<FirebaseException>()
                .having((e) => e.code, 'code', 'unauthorized')
                .having(
                  (e) => e.message,
                  'message',
                  'User is not authorized to perform the desired action.',
                ),
          ),
        );
      });
    });

    group('getDownloadURL', () {
      test(
        'gets a download url',
        () async {
          Reference storageReference = storage.ref('flutter-tests/ok.txt');

          expect(storageReference.bucket, secondStorageBucket);

          final task = storageReference.putString('test second bucket');
          final snapshot = await task;
          expect(snapshot.ref.bucket, secondStorageBucket);

          String url = await storageReference.getDownloadURL();

          expect(url, contains('/$secondStorageBucket/'));
        },
        // Fails on emulator since iOS SDK 10. See PR notes:
        // https://github.com/firebase/flutterfire/pull/9708
        skip: defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS,
      );

      test('errors if permission denied', () async {
        Reference ref = storage.ref('writeOnly.txt');

        await expectLater(
          () => ref.getDownloadURL(),
          throwsA(
            isA<FirebaseException>()
                .having((e) => e.code, 'code', 'unauthorized')
                .having(
                  (e) => e.message,
                  'message',
                  'User is not authorized to perform the desired action.',
                ),
          ),
        );
      });

      test('throws error if file does not exist', () async {
        Reference ref = storage.ref('flutter-tests/iDoNotExist.jpeg');

        await expectLater(
          () => ref.getDownloadURL(),
          throwsA(
            isA<FirebaseException>()
                .having((e) => e.code, 'code', 'object-not-found')
                .having(
                  (e) => e.message,
                  'message',
                  'No object exists at the desired reference.',
                ),
          ),
        );
      });
    });

    group(
      'list',
      () {
        test('returns list results', () async {
          Reference ref = storage.ref(allowableListsSecondBucket);
          ListResult result = await ref.list(const ListOptions(maxResults: 25));
          expect(result.items.length, greaterThan(0));
          expect(result.prefixes, isA<List<Reference>>());
        });

        test('errors if permission denied', () async {
          Reference ref = storage.ref('flutter-tests');

          await expectLater(
            () => ref.list(const ListOptions(maxResults: 25)),
            throwsA(
              isA<FirebaseException>()
                  .having((e) => e.code, 'code', 'unauthorized')
                  .having(
                    (e) => e.message,
                    'message',
                    'User is not authorized to perform the desired action.',
                  ),
            ),
          );
        });

        test('errors if maxResults is less than 0 ', () async {
          Reference ref = storage.ref('/list');
          expect(
            () => ref.list(const ListOptions(maxResults: -1)),
            throwsAssertionError,
          );
        });

        test('errors if maxResults is 0 ', () async {
          Reference ref = storage.ref('/list');
          expect(
            () => ref.list(const ListOptions(maxResults: 0)),
            throwsAssertionError,
          );
        });

        test('errors if maxResults is more than 1000 ', () async {
          Reference ref = storage.ref('/list');
          expect(
            () => ref.list(const ListOptions(maxResults: 1001)),
            throwsAssertionError,
          );
        });
      },
      skip: defaultTargetPlatform == TargetPlatform.windows,
    );

    test(
      'listAll',
      () async {
        Reference ref = storage.ref(allowableListsSecondBucket);
        ListResult result = await ref.listAll();
        expect(result.items, isNotNull);
        expect(result.items.length, greaterThan(0));
        expect(result.nextPageToken, isNull);

        expect(result.prefixes, isA<List<Reference>>());
      },
      skip: defaultTargetPlatform == TargetPlatform.windows,
    );

    group(
      'putData',
      () {
        test('uploads a file with buffer', () async {
          List<int> list = utf8.encode(kTestString);

          Uint8List data = Uint8List.fromList(list);

          final Reference ref =
              storage.ref('flutter-tests').child('flt-ok.txt');

          final TaskSnapshot complete = await ref.putData(
            data,
            SettableMetadata(
              contentLanguage: 'en',
            ),
          );

          expect(complete.metadata?.size, kTestString.length);
          // Metadata isn't saved on objects when using the emulator which fails test
          expect(complete.metadata?.contentLanguage, 'en');
        });

        test('errors if permission denied', () async {
          List<int> list = utf8.encode('hello world');
          Uint8List data = Uint8List.fromList(list);

          final Reference ref = storage.ref('/uploadNope.jpeg');

          await expectLater(
            () => ref.putData(data),
            throwsA(
              isA<FirebaseException>()
                  .having((e) => e.code, 'code', 'unauthorized')
                  .having(
                    (e) => e.message,
                    'message',
                    'User does not have permission to access this object',
                  ),
            ),
          );
        });
      },
      // Seems to throw an internal native exception
      skip: true,
    );

    group('putBlob', () {
      test(
        'throws [UnimplementedError] for native platforms',
        () async {
          final File file = await createFile('flt-ok.txt');
          final Reference ref =
              storage.ref('flutter-tests').child('flt-ok.txt');

          await expectLater(
            () => ref.putBlob(
              file,
              SettableMetadata(
                contentLanguage: 'en',
                customMetadata: <String, String>{'activity': 'test'},
              ),
            ),
            throwsA(
              isA<UnimplementedError>().having(
                (e) => e.message,
                'message',
                'putBlob() is not supported on native platforms. Use [put], [putFile] or [putString] instead.',
              ),
            ),
          );

          // This *must* be skipped in web, the test is intended for native platforms.
        },
        skip: kIsWeb,
      );
    });

    group(
      'putFile',
      () {
        test(
          'uploads a file',
          () async {
            final File file = await createFile('flt-ok.txt');

            final Reference ref =
                storage.ref('flutter-tests').child('flt-ok.txt');

            final TaskSnapshot complete = await ref.putFile(
              file,
              SettableMetadata(
                contentLanguage: 'en',
                customMetadata: <String, String>{'activity': 'test'},
              ),
            );

            expect(complete.metadata?.size, kTestString.length);
            // TODO - remove this note if still appplicable - Metadata isn't saved on objects when using the emulator which fails test
            expect(complete.metadata?.contentLanguage, 'en');
            expect(complete.metadata?.customMetadata!['activity'], 'test');
          },
        );

        test('errors if permission denied', () async {
          File file = await createFile('flt-ok.txt');
          final Reference ref = storage.ref('uploadNope.jpeg');

          await expectLater(
            () => ref.putFile(file),
            throwsA(
              isA<FirebaseException>()
                  .having((e) => e.code, 'code', 'unauthorized')
                  .having(
                    (e) => e.message,
                    'message',
                    'User is not authorized to perform the desired action.',
                  ),
            ),
          );
        });
      },
      // putFile is not supported in web.
      // iOS & macOS work locally but times out on CI. We ought to check this periodically
      // as it may be OS version specific.
      // seems to throw an internal native exception
      skip: true,
    );

    group('putString', () {
      test('uploads a string', () async {
        final Reference ref = storage.ref('flutter-tests').child('flt-ok.txt');
        final TaskSnapshot complete = await ref.putString('data');
        expect(complete.totalBytes, greaterThan(0));
      });

      // Emulator continues to make request rather than throw unauthorized exception as expected
      test(
        'errors if permission denied',
        () async {
          final Reference ref = storage.ref('uploadNope.jpeg');

          await expectLater(
            () => ref.putString('data'),
            throwsA(
              isA<FirebaseException>()
                  .having((e) => e.code, 'code', 'unauthorized')
                  .having(
                    (e) => e.message,
                    'message',
                    'User is not authorized to perform the desired action.',
                  ),
            ),
          );
        },
        // seems to throw an internal native exception
        skip: true,
      );
    });

    group('writeToFile', () {
      test(
        'writes a file',
        () async {
          File file = await createFile('ok.txt');
          TaskSnapshot complete =
              await storage.ref('flutter-tests/ok.txt').writeToFile(file);
          expect(complete.bytesTransferred, complete.totalBytes);
          expect(complete.state, TaskState.success);
          expect(complete.ref.bucket, secondStorageBucket);
        },
        skip: defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS,
      );
    });

    group('updateMetadata', () {
      test('updates metadata', () async {
        Reference ref = storage.ref('flutter-tests').child('flt-ok.txt');
        FullMetadata fullMetadata = await ref
            .updateMetadata(SettableMetadata(customMetadata: {'foo': 'bar'}));
        expect(fullMetadata.customMetadata!['foo'], 'bar');
        expect(fullMetadata.bucket, secondStorageBucket);
      });

      test(
        'errors if property does not exist',
        () async {
          Reference ref = storage.ref('flutter-tests/iDoNotExist.jpeg');

          await expectLater(
            () => ref.updateMetadata(SettableMetadata(contentType: 'unknown')),
            throwsA(
              isA<FirebaseException>()
                  .having((e) => e.code, 'code', 'object-not-found')
                  .having(
                    (e) => e.message,
                    'message',
                    'No object exists at the desired reference.',
                  ),
            ),
          );
        },
        // TODO(russellwheatley): raise issue on C++ SDK, if object does not exist, it throws "unauthorized" exception
        skip: defaultTargetPlatform == TargetPlatform.windows,
      );

      test(
        'errors if permission denied',
        () async {
          Reference ref =
              storage.ref('flutter-tests/second-bucket-not-allowed.jpeg');
          await expectLater(
            () => ref.updateMetadata(SettableMetadata(contentType: 'jpeg')),
            throwsA(
              isA<FirebaseException>()
                  .having((e) => e.code, 'code', 'unauthorized')
                  .having(
                    (e) => e.message,
                    'message',
                    'User is not authorized to perform the desired action.',
                  ),
            ),
          );
        },
      );
    });
  });
}
