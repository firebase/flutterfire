// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage_platform_interface/firebase_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'mock.dart';

const String testString = 'Hello World.';
MockReferencePlatform mockReferencePlatform = MockReferencePlatform();
MockUploadTaskPlatform mockUploadTaskPlatform = MockUploadTaskPlatform();
MockTaskSnapshotPlatform mockTaskSnapshotPlatform = MockTaskSnapshotPlatform();

void main() {
  setupFirebaseStorageMocks();

  late FirebaseStorage storage;
  late UploadTask uploadTask;

  group('Task', () {
    setUpAll(() async {
      FirebaseStoragePlatform.instance = kMockStoragePlatform;

      await Firebase.initializeApp();
      storage = FirebaseStorage.instance;

      when(kMockStoragePlatform.ref(any)).thenReturn(mockReferencePlatform);
      when(mockReferencePlatform.putString(any, any, any))
          .thenReturn(mockUploadTaskPlatform);
      uploadTask = storage.ref().putString(testString);
    });

    group('.snapshotEvents', () {
      test('verify delegate method is called', () async {
        when(mockUploadTaskPlatform.snapshotEvents)
            .thenAnswer((_) => Stream.fromIterable([mockTaskSnapshotPlatform]));

        final result = uploadTask.snapshotEvents;

        expect(result, isA<Stream<TaskSnapshot>>());
        verify(mockUploadTaskPlatform.snapshotEvents);
      });
    });

    group('.snapshot()', () {
      test('verify delegate method is called', () {
        when(mockUploadTaskPlatform.snapshot)
            .thenReturn(mockTaskSnapshotPlatform);

        final result = uploadTask.snapshot;

        expect(result, isA<TaskSnapshot>());
        verify(mockUploadTaskPlatform.snapshot);
      });
    });

    group('onComplete()', () {
      test('verify delegate method is called', () async {
        when(mockUploadTaskPlatform.onComplete)
            .thenAnswer((_) => Future.value(mockTaskSnapshotPlatform));

        final result = await uploadTask;

        expect(result, isA<TaskSnapshot>());

        verify(mockUploadTaskPlatform.onComplete);
      });
    });

    group('pause()', () {
      test('verify delegate method is called', () async {
        when(mockUploadTaskPlatform.pause())
            .thenAnswer((_) => Future.value(true));

        final result = await uploadTask.pause();

        expect(result, isA<bool>());
        expect(result, isTrue);

        verify(mockUploadTaskPlatform.pause());
      });
    });

    group('resume()', () {
      test('verify delegate method is called', () async {
        when(mockUploadTaskPlatform.resume())
            .thenAnswer((_) => Future.value(true));

        final result = await uploadTask.resume();

        expect(result, isA<bool>());
        expect(result, isTrue);

        verify(mockUploadTaskPlatform.resume());
      });
    });

    group('cancel()', () {
      test('verify delegate method is called', () async {
        when(mockUploadTaskPlatform.cancel())
            .thenAnswer((_) => Future.value(true));

        final result = await uploadTask.cancel();

        expect(result, isA<bool>());
        expect(result, isTrue);

        verify(mockUploadTaskPlatform.cancel());
      });
    });
  });
}
