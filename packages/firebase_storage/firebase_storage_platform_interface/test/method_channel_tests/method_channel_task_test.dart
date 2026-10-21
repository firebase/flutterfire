// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage_platform_interface/firebase_storage_platform_interface.dart';
import 'package:firebase_storage_platform_interface/src/method_channel/method_channel_firebase_storage.dart';
import 'package:firebase_storage_platform_interface/src/method_channel/method_channel_task.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mock.dart';

const String _observerId = 'task-observer';
const Duration _hangTimeout = Duration(seconds: 2);

class _TestTask extends MethodChannelTask {
  _TestTask(FirebaseStoragePlatform storage, [Future<String>? initialTask])
      : super(0, storage, '/foo', initialTask ?? Future.value(_observerId));
}

Map<String, Object?> _event(TaskState state, int bytesTransferred) => {
      'taskState': state.index,
      'appName': '[DEFAULT]',
      'snapshot': {
        'path': '/foo',
        'bytesTransferred': bytesTransferred,
        'totalBytes': 10,
      },
    };

Map<String, Object?> _errorEvent(String code) => {
      'taskState': TaskState.error.index,
      'appName': '[DEFAULT]',
      'error': {'code': code, 'message': 'error: $code'},
    };

void main() {
  setupFirebaseStorageMocks();

  late FirebaseStoragePlatform storage;
  late MockStreamHandlerEventSink nativeSink;
  late int nativeListenCount;
  late int nativeCancelCount;

  setUpAll(() async {
    final app = await Firebase.initializeApp();
    storage = MethodChannelFirebaseStorage(app: app, bucket: 'bucket');
  });

  setUp(() {
    nativeListenCount = 0;
    nativeCancelCount = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockStreamHandler(
      MethodChannelFirebaseStorage.storageTaskChannel(_observerId),
      MockStreamHandler.inline(
        onListen: (arguments, events) {
          nativeListenCount++;
          nativeSink = events;
          events.success(_event(TaskState.running, 1));
        },
        // On Android, cancelling the native stream used to cancel the task.
        onCancel: (arguments) => nativeCancelCount++,
      ),
    );
  });

  group('$MethodChannelTask', () {
    test(
        'cancelling the only snapshotEvents listener does not cancel the native '
        'task stream', () async {
      final task = _TestTask(storage);

      final first = await task.snapshotEvents.first;
      expect(first.state, TaskState.running);
      await pumpEventQueue();

      expect(nativeListenCount, 1);
      expect(nativeCancelCount, 0);
    });

    test('onComplete resolves after the snapshotEvents listener was cancelled',
        () async {
      final task = _TestTask(storage);
      await task.snapshotEvents.first;
      await pumpEventQueue();

      final onComplete = task.onComplete;
      nativeSink.success(_event(TaskState.success, 10));

      final snapshot = await onComplete.timeout(_hangTimeout);
      expect(snapshot.state, TaskState.success);
      expect(snapshot.bytesTransferred, 10);
      expect(task.snapshot.state, TaskState.success);
      expect(nativeListenCount, 1);
    });

    test(
        'a new snapshotEvents listener receives events after an earlier one '
        'was cancelled', () async {
      final task = _TestTask(storage);
      await task.snapshotEvents.first;
      await pumpEventQueue();

      final events = task.snapshotEvents.toList();
      nativeSink.success(_event(TaskState.running, 5));
      nativeSink.success(_event(TaskState.success, 10));

      final states =
          (await events.timeout(_hangTimeout)).map((s) => s.state).toList();
      expect(states, [TaskState.running, TaskState.success]);
    });

    test(
        'onComplete completes with an error if the native stream closes '
        'before a final state', () async {
      final task = _TestTask(storage);
      final onComplete = task.onComplete;
      await pumpEventQueue();

      nativeSink.endOfStream();

      await expectLater(
        onComplete.timeout(_hangTimeout),
        throwsA(isA<FirebaseException>()
            .having((e) => e.plugin, 'plugin', 'firebase_storage')),
      );
    });

    test(
        'snapshotEvents emits an error and closes if the native stream closes '
        'before a final state', () async {
      final task = _TestTask(storage);
      final errors = <Object>[];
      final done = Completer<void>();
      task.snapshotEvents.listen(
        (_) {},
        onError: errors.add,
        onDone: done.complete,
      );
      await pumpEventQueue();

      nativeSink.endOfStream();

      await done.future.timeout(_hangTimeout);
      expect(errors, [isA<FirebaseException>()]);
    });

    test('onComplete completes with an error if the task fails to start',
        () async {
      final initialTask = Completer<String>();
      final task = _TestTask(storage, initialTask.future);
      final onComplete = task.onComplete;

      initialTask
          .completeError(PlatformException(code: 'unknown', message: 'failed'));

      await expectLater(
        onComplete.timeout(_hangTimeout),
        throwsA(isA<FirebaseException>()
            .having((e) => e.code, 'code', 'unknown')
            .having((e) => e.message, 'message', 'failed')),
      );
      expect(nativeListenCount, 0);
    });

    test('an error is delivered to snapshotEvents and onComplete', () async {
      final task = _TestTask(storage);
      final streamErrors = <Object>[];
      final done = Completer<void>();
      task.snapshotEvents.listen(
        (_) {},
        onError: streamErrors.add,
        onDone: done.complete,
      );
      final onComplete = task.onComplete;
      await pumpEventQueue();

      nativeSink.success(_errorEvent('unauthorized'));

      await expectLater(
        onComplete,
        throwsA(isA<FirebaseException>()
            .having((e) => e.code, 'code', 'unauthorized')),
      );
      await done.future.timeout(_hangTimeout);
      expect(streamErrors, [
        isA<FirebaseException>().having((e) => e.code, 'code', 'unauthorized')
      ]);
      expect(task.snapshot.state, TaskState.error);
      await expectLater(
        task.onComplete,
        throwsA(isA<FirebaseException>()
            .having((e) => e.code, 'code', 'unauthorized')),
      );
    });

    test('an error without a snapshotEvents listener only fails onComplete',
        () async {
      final task = _TestTask(storage);
      final onComplete = task.onComplete;
      await pumpEventQueue();

      nativeSink.success(_errorEvent('canceled'));

      await expectLater(
        onComplete,
        throwsA(
            isA<FirebaseException>().having((e) => e.code, 'code', 'canceled')),
      );
    });

    test('a listener added after completion receives done', () async {
      final task = _TestTask(storage);
      final onComplete = task.onComplete;
      await pumpEventQueue();
      nativeSink.success(_event(TaskState.success, 10));
      await onComplete;

      await expectLater(task.snapshotEvents, emitsDone);
      expect((await task.onComplete).state, TaskState.success);
    });
  });
}
