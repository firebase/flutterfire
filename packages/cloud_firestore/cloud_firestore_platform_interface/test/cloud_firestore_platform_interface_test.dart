// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:cloud_firestore_platform_interface/src/method_channel_cloud_firestore.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('$CloudFirestorePlatform', () {
    test('$MethodChannelCloudFirestore is the default instance', () {
      expect(CloudFirestorePlatform.instance, isA<MethodChannelCloudFirestore>());
    });

    test('Cannot be implemented with `implements`', () {
      expect(() {
        CloudFirestorePlatform.instance = ImplementsCloudFirestorePlatform();
      }, throwsAssertionError);
    });

    test('Can be extended', () {
      CloudFirestorePlatform.instance = ExtendsCloudFirestorePlatform();
    });

    test('Can be mocked with `implements`', () {
      final ImplementsCloudFirestorePlatform mock =
          ImplementsCloudFirestorePlatform();
      when(mock.isMock).thenReturn(true);
      CloudFirestorePlatform.instance = mock;
    });
  });
}

class ImplementsCloudFirestorePlatform extends Mock
    implements CloudFirestorePlatform {}

class ExtendsCloudFirestorePlatform extends CloudFirestorePlatform {}
