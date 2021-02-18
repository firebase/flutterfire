// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage_platform_interface/src/method_channel/method_channel_list_result.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:firebase_storage_platform_interface/firebase_storage_platform_interface.dart';
import 'package:firebase_storage_platform_interface/src/method_channel/method_channel_firebase_storage.dart';
import '../mock.dart';

void main() {
  setupFirebaseStorageMocks();

  MethodChannelListResult? testListResult;

  group('$MethodChannelListResult', () {
    setUpAll(() async {
      FirebaseApp app = await Firebase.initializeApp();
      FirebaseStoragePlatform storage =
          MethodChannelFirebaseStorage(app: app, bucket: '');
      testListResult = MethodChannelListResult(
        storage,
        nextPageToken: '123',
        items: ['foo', 'bar'],
        prefixes: ['foo', 'bar'],
      );
    });

    group('items', () {
      test('should return successfully', () {
        final result = testListResult!.items;
        expect(result, isInstanceOf<List<ReferencePlatform>>());
        expect(result.length, equals(2));
      });
    });

    group('prefixes', () {
      test('should return successfully', () {
        final result = testListResult!.prefixes;
        expect(result, isInstanceOf<List<ReferencePlatform>>());
        expect(result.length, equals(2));
      });
    });
  });
}
