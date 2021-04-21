// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage_platform_interface/firebase_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'mock.dart';

const String testString = 'Hello World.';
const int testBytesTransferred = 11;
const int testTotalBytes = 20;
const Map<String, dynamic> testMetadata = <String, dynamic>{
  'contentType': 'gif'
};

MockReferencePlatform mockReferencePlatform = MockReferencePlatform();
MockUploadTaskPlatform mockUploadTaskPlatform = MockUploadTaskPlatform();
MockTaskSnapshotPlatform mockTaskSnapshotPlatform = MockTaskSnapshotPlatform();

void main() {
  setupFirebaseStorageMocks();
  late FirebaseStorage storage;
  late TaskSnapshot taskSnapshot;
  FullMetadata fullMetadata = FullMetadata(testMetadata);

  group('$TaskSnapshot', () {
    setUpAll(() async {
      FirebaseStoragePlatform.instance = kMockStoragePlatform;

      await Firebase.initializeApp();
      storage = FirebaseStorage.instance;
      when(kMockStoragePlatform.ref(any)).thenReturn(mockReferencePlatform);
      when(mockReferencePlatform.putString(any, any, any))
          .thenReturn(mockUploadTaskPlatform);
      when(mockUploadTaskPlatform.snapshot)
          .thenReturn(mockTaskSnapshotPlatform);

      UploadTask uploadTask = storage.ref().putString(testString);
      taskSnapshot = uploadTask.snapshot;
    });

    group('.bytesTransferred', () {
      test('verify delegate method is called', () {
        when(mockTaskSnapshotPlatform.bytesTransferred)
            .thenReturn(testBytesTransferred);

        expect(taskSnapshot.bytesTransferred, testBytesTransferred);
        verify(mockTaskSnapshotPlatform.bytesTransferred);
      });
    });

    group('.metadata', () {
      test('verify delegate method is called', () {
        when(mockTaskSnapshotPlatform.metadata).thenReturn(fullMetadata);

        final result = taskSnapshot.metadata!;

        expect(result, isA<FullMetadata>());
        expect(result.contentType, 'gif');

        verify(mockTaskSnapshotPlatform.metadata);
      });
    });

    group('.ref', () {
      test('verify delegate method is called', () {
        when(mockTaskSnapshotPlatform.ref).thenReturn(mockReferencePlatform);
        final result = taskSnapshot.ref;

        expect(result, isA<Reference>());
        verify(mockTaskSnapshotPlatform.ref);
      });
    });

    group('.state', () {
      test('verify delegate method is called', () {
        when(mockTaskSnapshotPlatform.state).thenReturn(TaskState.success);

        final result = taskSnapshot.state;

        expect(result, isA<TaskState>());
        verify(mockTaskSnapshotPlatform.state);
      });
    });

    group('.totalBytes', () {
      test('verify delegate method is called', () {
        when(mockTaskSnapshotPlatform.totalBytes).thenReturn(testTotalBytes);

        final result = taskSnapshot.totalBytes;

        expect(result, 20);
        verify(mockTaskSnapshotPlatform.totalBytes);
      });
    });
  });
}
