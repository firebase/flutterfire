// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart=2.9

import 'package:cloud_functions_platform_interface/cloud_functions_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

typedef Callback = Function(MethodCall call);

const String kTestString = 'Hello World';
const String kBucket = 'gs://fake-storage-bucket-url.com';
const String kSecondaryBucket = 'gs://fake-storage-bucket-url-2.com';
MockFirebaseFunctionsPlatform kMockFirebaseFunctionsPlatform;
final MockHttpsCallablePlatform kMockHttpsCallablePlatform =
    MockHttpsCallablePlatform();

void setupFirebaseFunctionsMocks() {
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
            'storageBucket': kBucket
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
}

// Platform Interface Mock Classes

// FirebaseFunctionsPlatform Mock
class MockFirebaseFunctionsPlatform extends Mock
    with
        // ignore: prefer_mixin, plugin_platform_interface needs to migrate to use `mixin`
        MockPlatformInterfaceMixin
    implements
        TestFirebaseFunctionsPlatform {
  MockFirebaseFunctionsPlatform(FirebaseApp app, String region) {
    TestFirebaseFunctionsPlatform(app, region);
  }
}

// HttpsCallablePlatform Mock
class MockHttpsCallablePlatform extends Mock
    with
        // ignore: prefer_mixin, plugin_platform_interface needs to migrate to use `mixin`
        MockPlatformInterfaceMixin
    implements
        HttpsCallablePlatform {}

class TestFirebaseFunctionsPlatform extends FirebaseFunctionsPlatform {
  TestFirebaseFunctionsPlatform(FirebaseApp app, String region)
      : super(app, region);

  void instanceFor({FirebaseApp app, Map<dynamic, dynamic> pluginConstants}) {}

  @override
  FirebaseFunctionsPlatform delegateFor({FirebaseApp app, String region}) {
    return this;
  }
}
