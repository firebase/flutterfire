// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase/firebase.dart' as fb;

import 'package:firebase_storage_platform_interface/firebase_storage_platform_interface.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:firebase_storage_web/src/task_snapshot_web.dart';
import 'package:mockito/mockito.dart';

import 'mocks/mocks.dart';

void runTaskSnapshotTests() {
  group('TaskSnapshotWeb', () {
    final FakeRef ref = FakeRef();
    MockUploadTaskSnapshot uploadTask;

    TaskSnapshotWeb snapshot;

    setUp(() {
      uploadTask = MockUploadTaskSnapshot();
      snapshot = TaskSnapshotWeb(ref, uploadTask);
      when(uploadTask.state).thenReturn(fb.TaskState.RUNNING);
    });

    test('constructor', () {
      expect(snapshot, isA<TaskSnapshotPlatform>());
    });

    test('returns same reference', () {
      expect(snapshot.ref, ref);
    });

    group('forwards calls: ', () {
      test('bytesTransferred', () {
        when(uploadTask.bytesTransferred).thenReturn(33930);
        expect(snapshot.bytesTransferred, 33930);
      });

      test('metadata (null)', () {
        expect(snapshot.metadata, isNull);
      });

      test('metadata', () {
        final mockMetadata = MockFullMetadata();
        when(mockMetadata.bucket).thenReturn('some-test-bucket-from-fake');
        when(mockMetadata.updated).thenReturn(DateTime.now());
        when(mockMetadata.timeCreated)
            .thenReturn(DateTime.now().subtract(Duration(seconds: 10)));
        when(uploadTask.metadata).thenReturn(mockMetadata);

        expect(snapshot.metadata.bucket, 'some-test-bucket-from-fake');
      });

      test('state', () {
        expect(snapshot.state, TaskState.running);
      });

      test('totalBytes', () {
        when(uploadTask.totalBytes).thenReturn(33930);

        expect(snapshot.totalBytes, 33930);
      });
    });
  });
}
