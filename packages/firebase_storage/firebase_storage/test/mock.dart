// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_storage_platform_interface/firebase_storage_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

typedef Callback(MethodCall call);

final String kTestString = 'Hello World';
final String kBucket = 'gs://fake-storage-bucket-url.com';
final String kSecondaryBucket = 'gs://fake-storage-bucket-url-2.com';
final MockFirebaseStorage kMockStoragePlatform = MockFirebaseStorage();

setupFirebaseStorageMocks() {
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

  // Mock Platform Interface Methods
  when(kMockStoragePlatform.delegateFor(
          app: anyNamed("app"), bucket: anyNamed("bucket")))
      .thenReturn(kMockStoragePlatform);

  when(kMockStoragePlatform.setInitialValues(
          maxDownloadRetryTime: anyNamed("maxDownloadRetryTime"),
          maxOperationRetryTime: anyNamed("maxOperationRetryTime"),
          maxUploadRetryTime: anyNamed("maxUploadRetryTime")))
      .thenReturn(kMockStoragePlatform);
  when(kMockStoragePlatform.maxOperationRetryTime).thenReturn(0);
  when(kMockStoragePlatform.maxDownloadRetryTime).thenReturn(0);
  when(kMockStoragePlatform.maxUploadRetryTime).thenReturn(0);
}

// Platform Interface Mock Classes

// FirebaseStoragePlatform Mock
class MockFirebaseStorage extends Mock
    with MockPlatformInterfaceMixin
    implements TestFirebaseStoragePlatform {
  MockFirebaseStorage() {
    TestFirebaseStoragePlatform();
  }
}

class TestFirebaseStoragePlatform extends FirebaseStoragePlatform {
  TestFirebaseStoragePlatform() : super();

  FirebaseStoragePlatform delegateFor({FirebaseApp app, String bucket}) {
    return this;
  }

  FirebaseStoragePlatform setInitialValues(
      {int maxOperationRetryTime,
      int maxDownloadRetryTime,
      int maxUploadRetryTime}) {
    return this;
  }
}

// ReferencePlatform Mock
class MockReferencePlatform extends Mock
    with MockPlatformInterfaceMixin
    implements ReferencePlatform {}

// ListResultPlatform Mock
class MockListResultPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements ListResultPlatform {}

// UploadTaskPlatform Mock
class MockUploadTaskPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements TaskPlatform {}

// DownloadTaskPlatform Mock
class MockDownloadTaskPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements TaskPlatform {}

// TaskSnapshotPlatform Mock
class MockTaskSnapshotPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements TaskSnapshotPlatform {}

// Creates a test file with a specified name to
// a locally directory
Future<File> createFile(name) async {
  final Directory systemTempDir = Directory.systemTemp;
  final File file = await File('${systemTempDir.path}/$name').create();
  await file.writeAsString(kTestString);
  return file;
}
