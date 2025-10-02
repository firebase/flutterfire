// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import './test_utils.dart';

void setupTaskTests() {
  group('Task', () {
    late FirebaseStorage storage;
    late File file;
    late Reference uploadRef;
    late Reference downloadRef;

    setUpAll(() async {
      storage = FirebaseStorage.instance;
      uploadRef = storage.ref('flutter-tests').child('ok.txt');
      downloadRef = storage.ref('flutter-tests/ok.txt'); // 15mb
    });

    group('pause() resume() onComplete()', () {
      late Task? task;

      setUp(() {
        task = null;
      });

      Future<void> _testPauseTask(String type) async {
        List<TaskSnapshot> snapshots = [];
        FirebaseException? streamError;
        expect(task!.snapshot.state, TaskState.running);

        task!.snapshotEvents.listen(
          (TaskSnapshot snapshot) {
            snapshots.add(snapshot);
          },
          onError: (error) {
            streamError = error;
          },
          cancelOnError: true,
        );

        // TODO(Salakar): Known issue with iOS SDK where pausing immediately will cause an 'unknown' error.
        if (defaultTargetPlatform == TargetPlatform.iOS) {
          await task!.snapshotEvents.first;
          await Future.delayed(const Duration(milliseconds: 750));
        }

        // TODO(Salakar): Known issue with iOS where pausing/resuming doesn't immediately return as paused/resumed 'true'.
        if (defaultTargetPlatform != TargetPlatform.iOS) {
          bool? paused = await task!.pause();
          expect(paused, isTrue);
          expect(task!.snapshot.state, TaskState.paused);

          await Future.delayed(const Duration(milliseconds: 500));

          bool? resumed = await task!.resume();
          expect(resumed, isTrue);
          expect(task!.snapshot.state, TaskState.running);
        }

        TaskSnapshot? snapshot = await task;
        expect(task!.snapshot.state, TaskState.success);
        expect(snapshot!.state, TaskState.success);

        expect(snapshot.totalBytes, snapshot.bytesTransferred);

        expect(streamError, isNull);
        // TODO(Salakar): Known issue with iOS where pausing/resuming doesn't immediately return as paused/resumed 'true'.
        if (defaultTargetPlatform != TargetPlatform.iOS) {
          expect(
            snapshots,
            anyElement(
              predicate<TaskSnapshot>(
                (TaskSnapshot element) => element.state == TaskState.paused,
              ),
            ),
          );
          expect(
            snapshots,
            anyElement(
              predicate<TaskSnapshot>(
                (TaskSnapshot element) => element.state == TaskState.running,
              ),
            ),
          );
        }
      }

      test(
        'successfully pauses and resumes a download task',
        () async {
          if (!kIsWeb) {
            file = await createFile('ok.jpeg');
            task = downloadRef.writeToFile(file);
          } else {
            task = downloadRef
                .putBlob(createBlob('some content to write to blob'));
          }
          await _testPauseTask('Download');
        },
        retry: 3,
        // TODO(russellwheatley): Windows works on example app, but fails on tests.
        // Clue is in bytesTransferred + totalBytes which both equal: -3617008641903833651
        skip: !kIsWeb && (
            defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.macOS
          ),
      );

      // TODO(Salakar): Test is flaky on CI - needs investigating ('[firebase_storage/unknown] An unknown error occurred, please check the server response.')
      test(
        'successfully pauses and resumes a upload task',
        () async {
          task = uploadRef.putString('This is an upload task!');
          await _testPauseTask('Upload');
        },
        retry: 3,
        // This task is flaky on mac, skip for now.
        // TODO(russellwheatley): Windows works on example app, but fails on tests.
        // Clue is in bytesTransferred + totalBytes which both equal: -3617008641903833651
        skip: !kIsWeb && (
            defaultTargetPlatform == TargetPlatform.macOS ||
            defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.android
          ),
      );

      test(
        'handles errors, e.g. if permission denied for `snapshotEvents`',
        () async {
          List<int> list = utf8.encode('hello world');
          Uint8List data = Uint8List.fromList(list);
          UploadTask task = storage.ref('/uploadNope.jpeg').putData(data);
          final Completer<FirebaseException> errorReceived =
              Completer<FirebaseException>();
          final Completer<bool> finished = Completer<bool>();

          task.snapshotEvents.listen(
            (TaskSnapshot snapshot) {
              // noop
            },
            onError: (error) {
              errorReceived.complete(error);
            },
            onDone: () {
              finished.complete(true);
            },
          );
          // Allow time for listener events to be called
          FirebaseException streamError = await errorReceived.future;

          expect(streamError.plugin, 'firebase_storage');
          expect(streamError.code, 'unauthorized');
          expect(
            streamError.message,
            'User is not authorized to perform the desired action.',
          );
          final complete = await finished.future;

          expect(complete, true);
          expect(task.snapshot.state, TaskState.error);
        },
      );

      test('handles errors, e.g. if permission denied for `await Task`',
          () async {
        List<int> list = utf8.encode('hello world');
        Uint8List data = Uint8List.fromList(list);
        UploadTask task = storage.ref('/uploadNope.jpeg').putData(data);
        try {
          await task;
        } catch (e) {
          expect(e, isA<FirebaseException>());
          FirebaseException exception = e as FirebaseException;
          expect(exception.plugin, 'firebase_storage');
          expect(exception.code, 'unauthorized');
          expect(
            exception.message,
            'User is not authorized to perform the desired action.',
          );
        }

        expect(task.snapshot.state, TaskState.error);
      });
    });

    group('snapshot', () {
      test(
        'returns the latest snapshot for download task',
        () async {
          Task downloadTask;
          if (!kIsWeb) {
            file = await createFile('ok.jpeg');
            downloadTask = downloadRef.writeToFile(file);
          } else {
            downloadTask = downloadRef
                .putBlob(createBlob('some content to write to blob'));
          }

          expect(downloadTask.snapshot, isNotNull);

          TaskSnapshot completedSnapshot = await downloadTask;
          final snapshot = downloadTask.snapshot;

          expect(snapshot, isA<TaskSnapshot>());
          expect(snapshot.state, TaskState.success);
          expect(snapshot.bytesTransferred, completedSnapshot.bytesTransferred);
          expect(snapshot.totalBytes, completedSnapshot.totalBytes);
          expect(snapshot.metadata, isA<FullMetadata?>());
        },
        retry: 2,
      );

      test(
        'returns the latest snapshot for upload task',
        () async {
          final uploadTask = uploadRef.putString('This is an upload task!');
          expect(uploadTask.snapshot, isNotNull);

          TaskSnapshot completedSnapshot = await uploadTask;
          final snapshot = uploadTask.snapshot;
          expect(snapshot, isA<TaskSnapshot>());
          expect(snapshot.bytesTransferred, completedSnapshot.bytesTransferred);
          expect(snapshot.totalBytes, completedSnapshot.totalBytes);
          expect(snapshot.metadata, isA<FullMetadata?>());
        },
        retry: 2,
      );
    });

    group(
      'cancel()',
      () {
        late Task task;

        Future<void> _testCancelTaskSnapshotEvents(Task task) async {
          List<TaskSnapshot> snapshots = [];
          expect(task.snapshot.state, TaskState.running);
          final Completer<FirebaseException> errorReceived =
              Completer<FirebaseException>();
          final Completer<bool> started = Completer<bool>();

          task.snapshotEvents.listen(
            (TaskSnapshot snapshot) {
              if (!started.isCompleted) {
                started.complete(true);
              }
              snapshots.add(snapshot);
            },
            onError: (error) {
              errorReceived.complete(error);
            },
          );

          await started.future;

          bool canceled = await task.cancel();
          expect(canceled, isTrue);
          expect(task.snapshot.state, TaskState.canceled);

          final streamError = await errorReceived.future;

          expect(streamError, isNotNull);
          expect(streamError.code, 'canceled');
          // Expecting there to only be running states, canceled should not get sent as an event.
          expect(
            snapshots.every((snapshot) => snapshot.state == TaskState.running),
            isTrue,
          );

          await expectLater(
            task,
            throwsA(
              isA<FirebaseException>()
                  .having((e) => e.code, 'code', 'canceled'),
            ),
          );
        }

        Future<void> _testCancelTaskLastEvent(Task task) async {
          expect(task.snapshot.state, TaskState.running);

          bool canceled = await task.cancel();
          expect(canceled, isTrue);
          expect(task.snapshot.state, TaskState.canceled);
        }

        test(
          'successfully cancels download task using snapshotEvents',
          () async {
            file = await createFile('ok.txt');
            // Need to put a large file in emulator first to test cancel.
            final initialPut = downloadRef.putFile(file);

            await initialPut;
            task = downloadRef.writeToFile(file);

            await _testCancelTaskSnapshotEvents(task);
          },
          // There's no DownloadTask on web.
          // Windows `task.cancel()` is returning "false", same code on example app works as intended
          skip: kIsWeb || defaultTargetPlatform == TargetPlatform.windows,
          retry: 2,
        );

        test(
          'successfully cancels download task and provides the last `canceled` event',
          () async {
            file = await createFile('ok.txt');
            final initialPut = downloadRef.putFile(file);

            await initialPut;
            task = downloadRef.writeToFile(file);
            await _testCancelTaskLastEvent(task);
          },
          // There's no DownloadTask on web.
          // Windows `task.cancel()` is returning "false", same code on example app works as intended
          skip: kIsWeb || defaultTargetPlatform == TargetPlatform.windows,
          retry: 2,
        );

        test(
          'successfully cancels upload task using snapshotEvents',
          () async {
            task = uploadRef.putString('A' * 20000000);
            await _testCancelTaskSnapshotEvents(task);
          },
          retry: 2,
          // Windows `task.cancel()` is returning "false", same code on example app works as intended
          skip: defaultTargetPlatform == TargetPlatform.windows,
        );

        test(
          'successfully cancels upload task and provides the last `canceled` event',
          () async {
            task = uploadRef.putString('A' * 20000000);
            await _testCancelTaskLastEvent(task);
          },
          retry: 2,
          // Windows `task.cancel()` is returning "false", same code on example app works as intended
          skip: defaultTargetPlatform == TargetPlatform.windows,
        );
      },
    );

    group('snapshotEvents', () {
      test('loop through successful `snapshotEvents`', () async {
        final snapshots = <TaskSnapshot>[];
        final task = uploadRef.putString('This is an upload task!');
        // ignore: prefer_foreach
        await for (final event in task.snapshotEvents) {
          snapshots.add(event);
        }
        expect(snapshots.last.state, TaskState.success);
      });

      test('failed `snapshotEvents` loop', () async {
        final snapshots = <TaskSnapshot>[];
        UploadTask task =
            storage.ref('/uploadNope.jpeg').putString('This will fail');
        try {
          // ignore: prefer_foreach
          await for (final event in task.snapshotEvents) {
            snapshots.add(event);
          }
        } catch (e) {
          expect(e, isA<FirebaseException>());
          FirebaseException exception = e as FirebaseException;
          expect(exception.plugin, 'firebase_storage');
          expect(exception.code, 'unauthorized');
          expect(
            exception.message,
            'User is not authorized to perform the desired action.',
          );
        }
      });

      test('listen to successful snapshotEvents, ensure `onDone` is called',
          () async {
        final Completer<bool> onDoneReceived = Completer<bool>();
        final snapshots = <TaskSnapshot>[];
        final task = uploadRef.putString('This is an upload task!');

        task.snapshotEvents.listen(
          snapshots.add,
          onDone: () {
            onDoneReceived.complete(true);
          },
        );

        final response = await onDoneReceived.future;
        expect(response, isTrue);
        expect(snapshots.last.state, TaskState.success);
      });

      test('listen to failed snapshotEvents, ensure `onDone` is called',
          () async {
        final snapshots = <TaskSnapshot>[];
        final task = storage
            .ref('/uploadNope.jpeg')
            .putString('This is an upload task!');
        final Completer<bool> onDoneReceived = Completer<bool>();
        FirebaseException? streamError;
        task.snapshotEvents.listen(
          snapshots.add,
          onError: (e) {
            streamError = e;
          },
          onDone: () {
            onDoneReceived.complete(true);
          },
        );

        final response = await onDoneReceived.future;
        expect(response, isTrue);
        expect(snapshots.last.state, TaskState.running);
        expect(streamError, isA<FirebaseException>());
      });
    });
  });
}
