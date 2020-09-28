// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

typedef Callback(MethodCall call);

final String kTestString = 'Hello World';
final String kBucket = 'gs://fake-messaging-bucket-url.com';
final String kSecondaryBucket = 'gs://fake-messaging-bucket-url-2.com';
final MockFirebaseMessaging kMockMessagingPlatform = MockFirebaseMessaging();

setupFirebaseMessagingMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelFirebase.channel.setMockMethodCallHandler((call) async {
    if (call.method == 'Firebase#initializeCore') {
      return [
        {
          'name': defaultFirebaseAppName,
          'options': {
            'apiKey': '123',
            'appId': '123',
            'messagingSenderId': '123',
            'projectId': '123',
            'messagingBucket': kBucket
          },
          'pluginConstants': {},
        }
      ];
    }

    if (call.method == 'Firebase#initializeApp') {
      return {
        'name': call.arguments['appName'],
        'options': call.arguments['options'],
        'pluginConstants': {},
      };
    }

    return null;
  });

  // Mock Platform Interface Methods
  when(kMockMessagingPlatform.delegateFor(
          app: anyNamed("app"), bucket: anyNamed("bucket")))
      .thenReturn(kMockMessagingPlatform);
}

// Platform Interface Mock Classes

// FirebaseMessagingPlatform Mock
class MockFirebaseMessaging extends Mock
    with MockPlatformInterfaceMixin
    implements TestFirebaseMessagingPlatform {
  MockFirebaseMessaging() {
    TestFirebaseMessagingPlatform();
  }
}

class TestFirebaseMessagingPlatform extends FirebaseMessagingPlatform {
  TestFirebaseMessagingPlatform() : super();

  FirebaseMessagingPlatform delegateFor({FirebaseApp app, String bucket}) {
    return this;
  }
}
