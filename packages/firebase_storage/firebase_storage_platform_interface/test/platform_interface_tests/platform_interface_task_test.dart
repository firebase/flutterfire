// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: avoid_catching_errors

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage_platform_interface/firebase_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../mock.dart';

void main() {
  setupFirebaseStorageMocks();

  TestTaskPlatform? taskPlatform;

  group('$TaskPlatform()', () {
    setUpAll(() async {
      await Firebase.initializeApp();
      taskPlatform = TestTaskPlatform();
    });

    test('Constructor', () {
      expect(taskPlatform, isA<TaskPlatform>());
      expect(taskPlatform, isA<PlatformInterface>());
    });

    group('verifyExtends()', () {
      test('calls successfully', () {
        try {
          TaskPlatform.verifyExtends(taskPlatform!);
          return;
        } catch (_) {
          fail('thrown an unexpected exception');
        }
      });
    });

    test('throws if get.snapshotEvents', () async {
      try {
        taskPlatform!.snapshotEvents;
      } on UnimplementedError catch (e) {
        expect(e.message, equals('snapshotEvents is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if get.snapshot', () async {
      try {
        taskPlatform!.snapshot;
      } on UnimplementedError catch (e) {
        expect(e.message, equals('snapshot is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if get.onComplete', () async {
      try {
        await taskPlatform!.onComplete;
      } on UnimplementedError catch (e) {
        expect(e.message, equals('onComplete is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if pause()', () async {
      try {
        await taskPlatform!.pause();
      } on UnimplementedError catch (e) {
        expect(e.message, equals('pause() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if resume()', () async {
      try {
        await taskPlatform!.resume();
      } on UnimplementedError catch (e) {
        expect(e.message, equals('resume() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if cancel()', () async {
      try {
        await taskPlatform!.cancel();
      } on UnimplementedError catch (e) {
        expect(e.message, equals('cancel() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });
  });
}

class TestTaskPlatform extends TaskPlatform {
  TestTaskPlatform() : super();
}
