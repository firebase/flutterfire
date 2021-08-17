// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage_platform_interface/firebase_storage_platform_interface.dart';
import 'package:firebase_storage_platform_interface/src/method_channel/method_channel_firebase_storage.dart';
import 'package:firebase_storage_platform_interface/src/method_channel/method_channel_reference.dart';
import 'package:firebase_storage_platform_interface/src/method_channel/method_channel_task.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mock.dart';

void main() {
  setupFirebaseStorageMocks();

  FirebaseStoragePlatform? storage;
  MethodChannelReference? ref;
  FirebaseApp? app;
  final List<MethodCall> log = <MethodCall>[];

  // mock props
  bool mockPlatformExceptionThrown = false;

  const kMockData = 'Hello World';
  late MethodChannelPutStringTask kMockTask;

  const kMockExceptionMessage = 'a mock exception message';

  group('$MethodChannelTask', () {
    setUpAll(() async {
      app = await Firebase.initializeApp();
      storage = MethodChannelFirebaseStorage(app: app!, bucket: '');
      ref = MethodChannelReference(storage!, '/');

      handleMethodCall((call) {
        log.add(call);

        if (mockPlatformExceptionThrown) {
          throw PlatformException(
              code: 'UNKNOWN', message: kMockExceptionMessage);
        }

        switch (call.method) {
          case 'Task#startPutString':
            return {}; // stub task request
          case 'Task#pause':
          case 'Task#resume':
          case 'Task#cancel':
            return {
              'status': true,
              'snapshot': {
                'path': ref!.fullPath,
                'bytesTransferred': 0,
                'totalBytes': 1,
              }
            };
          default:
            return true;
        }
      });

      kMockTask = ref!.putString(kMockData, PutStringFormat.raw)
          as MethodChannelPutStringTask;
    });

    setUp(() {
      mockPlatformExceptionThrown = false;
      log.clear();
    });

    test('snapshotEvents should return a stream of snapshots', () {
      final result = kMockTask.snapshotEvents;
      expect(result, isA<Stream<TaskSnapshotPlatform>>());
    });

    group('pause', () {
      test('should call native method with correct args', () async {
        int handle = nextMockHandleId;
        final result = await kMockTask.pause();
        expect(result, isA<bool>());
        expect(result, isTrue);
        expect(log, <Matcher>[
          isMethodCall(
            'Task#pause',
            arguments: <String, dynamic>{
              'handle': handle,
            },
          ),
        ]);
      });

      test(
          'catch a [PlatformException] error and throws a [FirebaseException] error',
          () async {
        mockPlatformExceptionThrown = true;
        Function callMethod;
        callMethod = () => kMockTask.pause();
        await testExceptionHandling('PLATFORM', callMethod);
      });
    });

    group('resume', () {
      test('should call native method with correct args', () async {
        final result = await kMockTask.resume();
        expect(result, isA<bool>());
        expect(result, isTrue);
        expect(log, <Matcher>[
          isMethodCall(
            'Task#resume',
            arguments: <String, dynamic>{
              'handle': 0,
            },
          ),
        ]);
      });

      test(
          'catch a [PlatformException] error and throws a [FirebaseException] error',
          () async {
        mockPlatformExceptionThrown = true;
        Function callMethod;
        callMethod = () => kMockTask.resume();
        await testExceptionHandling('PLATFORM', callMethod);
      });
    });

    group('cancel', () {
      test('should call native method with correct args', () async {
        final result = await kMockTask.cancel();
        expect(result, isA<bool>());
        expect(result, isTrue);
        expect(log, <Matcher>[
          isMethodCall(
            'Task#cancel',
            arguments: <String, dynamic>{
              'handle': 0,
            },
          ),
        ]);
      });

      test(
          'catch a [PlatformException] error and throws a [FirebaseException] error',
          () async {
        mockPlatformExceptionThrown = true;
        Function callMethod;
        callMethod = () => kMockTask.cancel();
        await testExceptionHandling('PLATFORM', callMethod);
      });
    });
  });
}
