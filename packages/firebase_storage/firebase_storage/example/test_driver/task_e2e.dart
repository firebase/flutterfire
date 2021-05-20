// @dart = 2.9

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import './test_utils.dart';

void runTaskTests() {
  group('Task', () {
    /*late*/ FirebaseStorage storage;
    /*late*/
    File file;
    /*late*/
    Reference uploadRef;
    /*late*/
    Reference downloadRef;

    setUpAll(() async {
      storage = FirebaseStorage.instance;
      uploadRef = storage.ref('flutter-tests').child('ok.txt');
      downloadRef = storage.ref('flutter-tests/ok.txt'); // 15mb
    });

    group('pause() resume() onComplete()', () {
      /*late*/ Task task;

      setUp(() {
        task = null;
      });

      Future<void> _testPauseTask(String type) async {
        List<TaskSnapshot> snapshots = [];
        FirebaseException streamError;
        expect(task.snapshot.state, TaskState.running);

        task.snapshotEvents.listen((TaskSnapshot snapshot) {
          snapshots.add(snapshot);
        }, onError: (error) {
          streamError = error;
        }, cancelOnError: true);

        // TODO(Salakar): Known issue with iOS SDK where pausing immediately will cause an 'unknown' error.
        if (defaultTargetPlatform == TargetPlatform.iOS) {
          await task.snapshotEvents.first;
          await Future.delayed(const Duration(milliseconds: 750));
        }

        // TODO(Salakar): Known issue with iOS where pausing/resuming doesn't immediately return as paused/resumed 'true'.
        if (defaultTargetPlatform != TargetPlatform.iOS) {
          bool paused = await task.pause();
          expect(paused, isTrue);
          expect(task.snapshot.state, TaskState.paused);

          bool resumed = await task.resume();
          expect(resumed, isTrue);
          expect(task.snapshot.state, TaskState.running);
        }

        TaskSnapshot snapshot = await task;
        expect(task.snapshot.state, TaskState.success);
        expect(snapshot.state, TaskState.success);

        expect(snapshot.totalBytes, snapshot.bytesTransferred);

        expect(streamError, isNull);
        // TODO(Salakar): Known issue with iOS where pausing/resuming doesn't immediately return as paused/resumed 'true'.
        if (defaultTargetPlatform != TargetPlatform.iOS) {
          expect(
              snapshots,
              anyElement(predicate<TaskSnapshot>((TaskSnapshot element) =>
                  element.state == TaskState.paused)));
          expect(
              snapshots,
              anyElement(predicate<TaskSnapshot>((TaskSnapshot element) =>
                  element.state == TaskState.running)));
        }
      }

      // TODO(Salakar): Test fails on emulator.
      test('successfully pauses and resumes a download task', () async {
        file = await createFile('ok.jpeg');
        task = downloadRef.writeToFile(file);
        await _testPauseTask('Download');
        // There's no DownloadTask in web.
      }, skip: true);

      // TODO(Salakar): Test is flaky on CI - needs investigating ('[firebase_storage/unknown] An unknown error occurred, please check the server response.')
      test('successfully pauses and resumes a upload task', () async {
        task = uploadRef.putString('This is an upload task!');
        await _testPauseTask('Upload');
      }, skip: true);

      test('handles errors, e.g. if permission denied', () async {
        /*late*/ FirebaseException streamError;

        List<int> list = utf8.encode('hello world');
        Uint8List data = Uint8List.fromList(list);
        UploadTask task = storage.ref('/uploadNope.jpeg').putData(data);

        expect(task.snapshot.state, TaskState.running);

        task.snapshotEvents.listen((TaskSnapshot snapshot) {
          // noop
        }, onError: (error) {
          streamError = error;
        }, cancelOnError: true);

        await expectLater(
            task,
            throwsA(isA<FirebaseException>()
                .having((e) => e.code, 'code', 'unauthorized')));

        expect(streamError.plugin, 'firebase_storage');
        expect(streamError.code, 'unauthorized');
        expect(streamError.message,
            'User is not authorized to perform the desired action.');

        expect(task.snapshot.state, TaskState.error);
      });
    });

    group('snapshot', () {
      test('returns the latest snapshot for download task', () async {
        file = await createFile('ok.jpeg');
        final downloadTask = downloadRef.writeToFile(file);

        expect(downloadTask.snapshot, isNotNull);

        TaskSnapshot completedSnapshot = await downloadTask;
        final snapshot = downloadTask.snapshot;

        expect(snapshot, isA<TaskSnapshot>());
        expect(snapshot.state, TaskState.success);
        expect(snapshot.bytesTransferred, completedSnapshot.bytesTransferred);
        expect(snapshot.totalBytes, completedSnapshot.totalBytes);
        expect(snapshot.metadata, isNull);
        // There's no DownloadTask in web.
      }, skip: kIsWeb);

      test('returns the latest snapshot for upload task', () async {
        final uploadTask = uploadRef.putString('This is an upload task!');
        expect(uploadTask.snapshot, isNotNull);

        TaskSnapshot completedSnapshot = await uploadTask;
        final snapshot = uploadTask.snapshot;
        expect(snapshot, isA<TaskSnapshot>());
        expect(snapshot.bytesTransferred, completedSnapshot.bytesTransferred);
        expect(snapshot.totalBytes, completedSnapshot.totalBytes);
        expect(snapshot.metadata, isA<FullMetadata>());
      });

      // TODO(ehesp): secondary bucket not accessible - check if emulator issue
      // test('upload task to a custom bucket', () async {
      //   String secondaryBucket = 'gs://secondary-bucket';
      //   Reference storageReference =
      //       FirebaseStorage.instanceFor(bucket: secondaryBucket)
      //           .ref('flutter-tests/ok.txt');
      //
      //   UploadTask task = storageReference.putString('test second bucket');
      //
      //   TaskSnapshot snapshot = await task;
      //
      //   String url = await snapshot.ref.getDownloadURL();
      //
      //   expect(url, contains('/$secondaryBucket/'));
      // });
    });

    // TODO(Salakar): Test fails on emulator.
    group('cancel()', () {
      /*late*/ Task /*!*/ task;

      Future<void> _testCancelTask() async {
        List<TaskSnapshot> snapshots = [];
        FirebaseException streamError;
        expect(task.snapshot.state, TaskState.running);

        task.snapshotEvents.listen((TaskSnapshot snapshot) {
          snapshots.add(snapshot);
        }, onError: (error) {
          streamError = error;
        }, cancelOnError: true);

        bool canceled = await task.cancel();
        expect(canceled, isTrue);
        expect(task.snapshot.state, TaskState.canceled);

        await expectLater(
            task,
            throwsA(isA<FirebaseException>()
                .having((e) => e.code, 'code', 'canceled')));

        expect(task.snapshot.state, TaskState.canceled);

        expect(streamError, isNotNull);
        expect(streamError.code, 'canceled');
        // Expecting there to only be running states, canceled should not get sent as an event.
        expect(
            snapshots.every((snapshot) => snapshot.state == TaskState.running),
            isTrue);
      }

      test('successfully cancels download task', () async {
        file = await createFile('ok.jpeg');
        task = downloadRef.writeToFile(file);
        await _testCancelTask();
        // There's no DownloadTask in web.
        // TODO(Salakar): Test fails on emulator.
      }, skip: true);

      test('successfully cancels upload task', () async {
        task = uploadRef.putString('This is an upload task!');
        await _testCancelTask();
      });
    }, skip: true);
  });
}
