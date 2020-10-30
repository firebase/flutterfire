import 'dart:async';
import 'package:firebase/firebase.dart' as fb;

import 'package:firebase_storage_platform_interface/firebase_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:firebase_storage_web/src/task_web.dart';
import 'package:mockito/mockito.dart';

import 'mocks/mocks.dart';

void runTaskTests() {
  group('TaskWeb', () {
    final FakeRef ref = FakeRef();
    MockUploadTask uploadTask;
    MockUploadTaskSnapshot snapshot;

    TaskWeb task;

    setUp(() {
      uploadTask = MockUploadTask();
      snapshot = MockUploadTaskSnapshot();
      when(uploadTask.snapshot).thenReturn(snapshot);

      task = TaskWeb(ref, uploadTask);
    });

    test('constructor', () {
      expect(task, isA<TaskPlatform>());
    });

    group('async', () {
      Completer<MockUploadTaskSnapshot> completer;
      StreamController<MockUploadTaskSnapshot> controller;

      setUp(() {
        completer = Completer();
        controller = StreamController();
        when(uploadTask.future).thenAnswer((_) => completer.future);
        when(uploadTask.onStateChanged).thenAnswer((_) => controller.stream);
      });

      group('onComplete', () {
        test('does not connected by default', () {
          verifyNever(uploadTask.future);
        });

        test('connects to the underlying .future', () {
          final value = task.onComplete;

          expect(value, isNotNull);
          verify(uploadTask.future);
        });

        test('resolved future is linked to the original ref', () async {
          final snapshot = task.onComplete;

          verify(uploadTask.future);

          completer.complete(MockUploadTaskSnapshot());

          expect((await snapshot).ref, ref);
        });
      });

      group('snapshotEvents', () {
        test('not connected by default', () {
          verifyNever(uploadTask.onStateChanged);
        });

        test('connects both to the underlying stream, but also to the future',
            () {
          task.snapshotEvents;

          verify(uploadTask.onStateChanged);
          verify(uploadTask.future);
        });

        test('onStateChange events pass through snapshotEvents', () async {
          final snapshot = task.snapshotEvents.first;

          controller.add(MockUploadTaskSnapshot());

          expect((await snapshot).ref, ref);
        });

        test('future event passes through snapshotEvents', () async {
          final snapshot = task.snapshotEvents.first;

          completer.complete(MockUploadTaskSnapshot());

          expect((await snapshot).ref, ref);
        });
      });
    });

    group('forwards calls: ', () {
      test('snapshot', () {
        final snapshot = task.snapshot;
        verify(uploadTask.snapshot);
        expect(snapshot.ref, ref);
      });

      test('cancel', () {
        task.cancel();
        verify(uploadTask.cancel());
      });

      test('pause', () {
        task.pause();
        verify(uploadTask.pause());
      });

      test('resume', () {
        task.resume();
        verify(uploadTask.resume());
      });
    });
  });
}
