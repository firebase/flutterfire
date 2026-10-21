// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage_platform_interface/firebase_storage_platform_interface.dart';
import 'package:firebase_storage_platform_interface/src/method_channel/method_channel_firebase_storage.dart';
import 'package:firebase_storage_platform_interface/src/method_channel/method_channel_task.dart';
import 'package:firebase_storage_platform_interface/src/pigeon/messages.pigeon.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../mock.dart';
import '../pigeon/test_api.dart';

const _observerId = 'put-data-observer';

class _MockFirebaseStorageHostApi extends Mock
    implements TestFirebaseStorageHostApi {
  @override
  Future<String> referencePutData(
    InternalStorageFirebaseApp app,
    InternalStorageReference reference,
    Uint8List data,
    InternalSettableMetadata settableMetaData,
    int handle,
  ) async {
    return _observerId;
  }
}

void main() {
  setupFirebaseStorageMocks();

  late FirebaseStoragePlatform storage;

  setUpAll(() async {
    final app = await Firebase.initializeApp();
    storage = MethodChannelFirebaseStorage(app: app, bucket: 'bucket-test');
  });

  setUp(() {
    TestFirebaseStorageHostApi.setUp(_MockFirebaseStorageHostApi());
  });

  tearDown(() {
    TestFirebaseStorageHostApi.setUp(null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockStreamHandler(
      MethodChannelFirebaseStorage.storageTaskChannel(_observerId),
      null,
    );
  });

  test('keeps the last metadata when the task fails', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockStreamHandler(
      MethodChannelFirebaseStorage.storageTaskChannel(_observerId),
      MockStreamHandler.inline(
        onListen: (arguments, events) {
          events.success(<String, Object?>{
            'taskState': TaskState.running.index,
            'snapshot': <String, Object?>{
              'path': 'foo/bar',
              'bytesTransferred': 1,
              'totalBytes': 2,
              'metadata': <String, Object?>{'contentType': 'text/plain'},
            },
          });
          events.success(<String, Object?>{
            'taskState': TaskState.error.index,
            'error': <String, Object?>{
              'code': 'unauthorized',
              'message': 'User is not authorized.',
            },
          });
        },
      ),
    );

    final task = MethodChannelPutTask(
      nextMockHandleId,
      storage,
      'foo/bar',
      Uint8List.fromList([1, 2]),
      null,
    );

    await expectLater(
      task.snapshotEvents,
      emitsInOrder([
        isA<TaskSnapshotPlatform>(),
        emitsError(isA<FirebaseException>()),
      ]),
    );

    expect(task.snapshot.state, TaskState.error);
    expect(task.snapshot.bytesTransferred, 1);
    expect(task.snapshot.metadata?.contentType, 'text/plain');
  });
}
