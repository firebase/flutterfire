import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import './test_utils.dart';

void runTaskTests() {
  group('Task', () {
    FirebaseStorage storage;
    File file;
    Reference uploadRef;
    Reference downloadRef;

    setUpAll(() async {
      storage = FirebaseStorage.instance;
      file = await createFile('ok.jpeg');
      uploadRef = storage.ref('/playground').child('flt-ok.txt');
      downloadRef = storage.ref('/smallFileTest.png'); // 15mb
    });

    group('pause() resume() onComplete()', () {
      Task task;

      setUp(() {
        task = null;
      });

      final _testPauseTask = (String type) async {
        List<TaskSnapshot> snapshots = [];
        FirebaseException streamError;
        expect(task.snapshot.state, TaskState.running);

        task.snapshotEvents.listen((TaskSnapshot snapshot) {
          snapshots.add(snapshot);
        }, onError: (error) {
          streamError = error;
        }, cancelOnError: true);

        await task.snapshotEvents.first;
        if (defaultTargetPlatform == TargetPlatform.iOS) {
          await Future.delayed(Duration(milliseconds: 750));
        }
        bool paused = await task.pause();
        expect(paused, isTrue);
        expect(task.snapshot.state, TaskState.paused);

        bool resumed = await task.resume();
        expect(resumed, isTrue);
        expect(task.snapshot.state, TaskState.running);

        TaskSnapshot snapshot = await task;
        expect(task.snapshot.state, TaskState.success);
        expect(snapshot.state, TaskState.success);

        expect(snapshot.totalBytes, snapshot.bytesTransferred);

        expect(streamError, isNull);
        expect(
            snapshots,
            anyElement(predicate<TaskSnapshot>(
                (TaskSnapshot element) => element.state == TaskState.paused)));
        expect(
            snapshots,
            anyElement(predicate<TaskSnapshot>(
                (TaskSnapshot element) => element.state == TaskState.running)));
      };

      test('successfully pauses and resumes a download task', () async {
        task = downloadRef.writeToFile(file);
        await _testPauseTask('Download');
      });

      test('successfully pauses and resumes a upload task', () async {
        await downloadRef.writeToFile(file);
        task = uploadRef.putFile(file);
        await _testPauseTask('Upload');
      }, skip: false);
    });

    group('snapshot', () {
      test('returns the latest snapshot for download task', () async {
        final downloadTask = downloadRef.writeToFile(file);

        expect(downloadTask.snapshot, isNotNull);

        TaskSnapshot completedSnapshot = await downloadTask;
        final snapshot = downloadTask.snapshot;

        expect(snapshot, isA<TaskSnapshot>());
        expect(snapshot.state, TaskState.success);
        expect(snapshot.bytesTransferred, completedSnapshot.bytesTransferred);
        expect(snapshot.totalBytes, completedSnapshot.totalBytes);
        expect(snapshot.metadata, isNull);
      });

      test('returns the latest snapshot for upload task', () async {
        final uploadTask = uploadRef.putFile(file);
        expect(uploadTask.snapshot, isNotNull);

        TaskSnapshot completedSnapshot = await uploadTask;
        final snapshot = uploadTask.snapshot;
        expect(snapshot, isA<TaskSnapshot>());
        expect(snapshot.bytesTransferred, completedSnapshot.bytesTransferred);
        expect(snapshot.totalBytes, completedSnapshot.totalBytes);
        expect(snapshot.metadata, isA<FullMetadata>());
      });
    });

    group('cancel()', () {
      Task task;

      setUp(() {
        task = null;
      });

      final _testCancelTask = () async {
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

        try {
          await task;
          return Future.error('Task did not error & cancel.');
        } on FirebaseException catch (e) {
          expect(e.code, 'canceled');
          expect(task.snapshot.state, TaskState.canceled);
        } catch (e) {
          return Future.error(
              'Task did not error with a FirebaseException instance.');
        }

        expect(streamError, isNotNull);
        expect(streamError.code, 'canceled');
        // Expecting there to only be running states, canceled should not get sent as an event.
        expect(
            snapshots.every((snapshot) => snapshot.state == TaskState.running),
            isTrue);
      };

      test('successfully cancels download task', () async {
        task = downloadRef.writeToFile(file);
        await _testCancelTask();
      });

      test('successfully cancels upload task', () async {
        task = uploadRef.putFile(file);
        await _testCancelTask();
      });
    });
  });
}
