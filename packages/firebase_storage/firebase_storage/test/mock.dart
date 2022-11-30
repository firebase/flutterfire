// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
// TODO(Lyokone): remove once we bump Flutter SDK min version to 3.3
// ignore: unnecessary_import
import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_storage_platform_interface/firebase_storage_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

typedef Callback = Function(MethodCall call);

const String kTestString = 'Hello World';
const String kBucket = 'gs://fake-storage-bucket-url.com';
const String kSecondaryBucket = 'gs://fake-storage-bucket-url-2.com';

const String testString = 'Hello World';
const String testBucket = 'test-bucket';

const String testName = 'bar';
const String testFullPath = 'foo/$testName';

const String testToken = 'mock-token';
const String testParent = 'test-parent';
const String testDownloadUrl = 'test-download-url';
const Map<String, dynamic> testMetadataMap = <String, dynamic>{
  'contentType': 'gif'
};
const int testMaxResults = 1;
const String testPageToken = 'test-page-token';

final MockFirebaseStorage kMockStoragePlatform = MockFirebaseStorage();

class MockFirebaseAppStorage implements TestFirebaseCoreHostApi {
  @override
  Future<PigeonInitializeResponse> initializeApp(
    String appName,
    PigeonFirebaseOptions initializeAppRequest,
  ) async {
    return PigeonInitializeResponse(
      name: appName,
      options: initializeAppRequest,
      pluginConstants: {},
    );
  }

  @override
  Future<List<PigeonInitializeResponse?>> initializeCore() async {
    return [
      PigeonInitializeResponse(
        name: defaultFirebaseAppName,
        options: PigeonFirebaseOptions(
          apiKey: '123',
          projectId: '123',
          appId: '123',
          messagingSenderId: '123',
          storageBucket: kBucket,
        ),
        pluginConstants: {},
      )
    ];
  }

  @override
  Future<PigeonFirebaseOptions> optionsFromResource() async {
    return PigeonFirebaseOptions(
      apiKey: '123',
      projectId: '123',
      appId: '123',
      messagingSenderId: '123',
      storageBucket: kBucket,
    );
  }
}

void setupFirebaseStorageMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();

  TestFirebaseCoreHostApi.setup(MockFirebaseAppStorage());

  // Mock Platform Interface Methods
  when(kMockStoragePlatform.delegateFor(
          app: anyNamed('app'), bucket: anyNamed('bucket')))
      .thenReturn(kMockStoragePlatform);
}

// Platform Interface Mock Classes

// FirebaseStoragePlatform Mock
class MockFirebaseStorage extends Mock
    with
        // ignore: prefer_mixin, plugin_platform_interface needs to migrate to use `mixin`
        MockPlatformInterfaceMixin
    implements
        TestFirebaseStoragePlatform {
  MockFirebaseStorage() {
    TestFirebaseStoragePlatform();
  }

  @override
  final int maxOperationRetryTime = 0;
  @override
  final int maxDownloadRetryTime = 0;
  @override
  final int maxUploadRetryTime = 0;

  @override
  FirebaseStoragePlatform delegateFor({FirebaseApp? app, String? bucket}) {
    return super.noSuchMethod(
        Invocation.method(#delegateFor, [], {#app: app, #bucket: bucket}),
        returnValue: TestFirebaseStoragePlatform());
  }

  @override
  ReferencePlatform ref(String? path) {
    return super.noSuchMethod(Invocation.method(#ref, [path]),
        returnValue: TestReferencePlatform(),
        returnValueForMissingStub: TestReferencePlatform());
  }

  @override
  Future<void> useStorageEmulator(String host, int port) async {
    return super
        .noSuchMethod(Invocation.method(#useStorageEmulator, [host, port]));
  }
}

class TestFirebaseStoragePlatform extends FirebaseStoragePlatform {
  TestFirebaseStoragePlatform() : super(bucket: testBucket);

  @override
  FirebaseStoragePlatform delegateFor({FirebaseApp? app, String? bucket}) {
    return this;
  }
}

// ReferencePlatform Mock
class TestReferencePlatform extends ReferencePlatform {
  TestReferencePlatform() : super(TestFirebaseStoragePlatform(), testFullPath);
// @override
}

// ReferencePlatform Mock
class MockReferencePlatform extends Mock
    with
        // ignore: prefer_mixin, plugin_platform_interface needs to migrate to use `mixin`
        MockPlatformInterfaceMixin
    implements
        ReferencePlatform {
  @override
  Future<ListResultPlatform> list([ListOptions? options]) {
    return super.noSuchMethod(Invocation.method(#list, [options]),
        returnValue: neverEndingFuture<ListResultPlatform>(),
        returnValueForMissingStub: neverEndingFuture<ListResultPlatform>());
  }

  @override
  TaskPlatform putData(Uint8List data, [SettableMetadata? metadata]) {
    return super.noSuchMethod(Invocation.method(#putData, [data, metadata]),
        returnValue: TestUploadTaskPlatform(),
        returnValueForMissingStub: TestUploadTaskPlatform());
  }

  @override
  TaskPlatform putFile(File file, [SettableMetadata? metadata]) {
    return super.noSuchMethod(Invocation.method(#putFile, [file, metadata]),
        returnValue: TestUploadTaskPlatform(),
        returnValueForMissingStub: TestUploadTaskPlatform());
  }

  @override
  Future<FullMetadata> updateMetadata(SettableMetadata metadata) {
    return super.noSuchMethod(Invocation.method(#updateMetadata, [metadata]),
        returnValue: neverEndingFuture<FullMetadata>(),
        returnValueForMissingStub: neverEndingFuture<FullMetadata>());
  }

  @override
  String get bucket {
    return super.noSuchMethod(Invocation.getter(#bucket),
        returnValue: testBucket, returnValueForMissingStub: testBucket);
  }

  @override
  String get fullPath {
    return super.noSuchMethod(Invocation.getter(#fullPath),
        returnValue: testFullPath, returnValueForMissingStub: testBucket);
  }

  @override
  String get name {
    return super.noSuchMethod(Invocation.getter(#name),
        returnValue: testName, returnValueForMissingStub: testName);
  }

  @override
  ReferencePlatform? get parent {
    return super.noSuchMethod(Invocation.getter(#parent),
        returnValue: TestListResultPlatform(),
        returnValueForMissingStub: TestListResultPlatform());
  }

  @override
  TaskPlatform putBlob(dynamic data, [SettableMetadata? metadata]) {
    return super.noSuchMethod(Invocation.method(#putBlob, [data, metadata]),
        returnValue: TestUploadTaskPlatform(),
        returnValueForMissingStub: TestUploadTaskPlatform());
  }

  @override
  TaskPlatform writeToFile(File file) {
    return super.noSuchMethod(Invocation.method(#writeToFile, [file]),
        returnValue: TestUploadTaskPlatform(),
        returnValueForMissingStub: TestUploadTaskPlatform());
  }

  @override
  ReferencePlatform get root {
    return super.noSuchMethod(Invocation.getter(#root),
        returnValue: TestReferencePlatform(),
        returnValueForMissingStub: TestListResultPlatform());
  }

  @override
  ReferencePlatform child(String path) {
    return super.noSuchMethod(Invocation.method(#child, [], {#path: path}),
        returnValue: TestReferencePlatform(),
        returnValueForMissingStub: TestListResultPlatform());
  }

  @override
  Future<void> delete() {
    return super.noSuchMethod(Invocation.method(#delete, []),
        returnValue: neverEndingFuture<void>(),
        returnValueForMissingStub: neverEndingFuture<void>());
  }

  @override
  TaskPlatform putString(String? data, PutStringFormat? format,
      [SettableMetadata? metadata]) {
    return super.noSuchMethod(
        Invocation.method(#child, [data, format, metadata]),
        returnValue: TestUploadTaskPlatform(),
        returnValueForMissingStub: TestUploadTaskPlatform());
  }

  @override
  Future<String> getDownloadURL() {
    return super.noSuchMethod(Invocation.method(#getDownloadURL, []),
        returnValue: neverEndingFuture<String>(),
        returnValueForMissingStub: neverEndingFuture<String>());
  }

  @override
  Future<FullMetadata> getMetadata() {
    return super.noSuchMethod(Invocation.method(#getMetadata, []),
        returnValue: neverEndingFuture<FullMetadata>(),
        returnValueForMissingStub: neverEndingFuture<FullMetadata>());
  }

  @override
  Future<ListResultPlatform> listAll() {
    return super.noSuchMethod(Invocation.method(#listAll, []),
        returnValue: neverEndingFuture<ListResultPlatform>(),
        returnValueForMissingStub: neverEndingFuture<ListResultPlatform>());
  }
}

// UploadTaskPlatform Mock
class MockUploadTaskPlatform extends Mock
    with
        // ignore: prefer_mixin, plugin_platform_interface needs to migrate to use `mixin`
        MockPlatformInterfaceMixin
    implements
        TaskPlatform {
  @override
  TaskSnapshotPlatform get snapshot {
    return super.noSuchMethod(Invocation.getter(#snapshot),
        returnValue: TestTaskSnapshotPlatform(),
        returnValueForMissingStub: TestTaskSnapshotPlatform());
  }

  @override
  Stream<TaskSnapshotPlatform> get snapshotEvents {
    return super.noSuchMethod(Invocation.getter(#snapshotEvents),
        returnValue: const Stream<TaskSnapshotPlatform>.empty(),
        returnValueForMissingStub: const Stream<TaskSnapshotPlatform>.empty());
  }

  @override
  Future<TaskSnapshotPlatform> get onComplete {
    return super.noSuchMethod(Invocation.getter(#onComplete),
        returnValue: neverEndingFuture<TaskSnapshotPlatform>(),
        returnValueForMissingStub: neverEndingFuture<TaskSnapshotPlatform>());
  }

  @override
  Future<bool> pause() {
    return super.noSuchMethod(Invocation.method(#pause, []),
        returnValue: Future.value(false),
        returnValueForMissingStub: Future.value(false));
  }

  @override
  Future<bool> resume() {
    return super.noSuchMethod(Invocation.method(#resume, []),
        returnValue: Future.value(false),
        returnValueForMissingStub: Future.value(false));
  }

  @override
  Future<bool> cancel() {
    return super.noSuchMethod(Invocation.method(#cancel, []),
        returnValue: Future.value(false),
        returnValueForMissingStub: Future.value(false));
  }
}

class TestListResultPlatform extends ReferencePlatform {
  TestListResultPlatform() : super(TestFirebaseStoragePlatform(), testFullPath);
}

class TestTaskSnapshotPlatform extends TaskSnapshotPlatform {
  TestTaskSnapshotPlatform() : super(TaskState.running, {});
}

// ListResultPlatform Mock
class MockListResultPlatform extends Mock
    with
        // ignore: prefer_mixin, plugin_platform_interface needs to migrate to use `mixin`
        MockPlatformInterfaceMixin
    implements
        ListResultPlatform {
  @override
  List<ReferencePlatform> get items {
    return super.noSuchMethod(Invocation.getter(#items),
        returnValue: <ReferencePlatform>[],
        returnValueForMissingStub: <ReferencePlatform>[]);
  }

  @override
  String? get nextPageToken {
    return super.noSuchMethod(Invocation.getter(#nextPageToken),
        returnValue: testToken, returnValueForMissingStub: testToken);
  }

  @override
  List<ReferencePlatform> get prefixes {
    return super.noSuchMethod(Invocation.getter(#prefixes),
        returnValue: <ReferencePlatform>[],
        returnValueForMissingStub: <ReferencePlatform>[]);
  }
}

class TestUploadTaskPlatform extends TaskPlatform {
  TestUploadTaskPlatform() : super();
}

// DownloadTaskPlatform Mock
class MockDownloadTaskPlatform extends Mock
    with
        // ignore: prefer_mixin, plugin_platform_interface needs to migrate to use `mixin`
        MockPlatformInterfaceMixin
    implements
        TaskPlatform {}

// TaskSnapshotPlatform Mock
class MockTaskSnapshotPlatform extends Mock
    with
        // ignore: prefer_mixin, plugin_platform_interface needs to migrate to use `mixin`
        MockPlatformInterfaceMixin
    implements
        TaskSnapshotPlatform {
  @override
  int get bytesTransferred {
    return super.noSuchMethod(Invocation.getter(#bytesTransferred),
        returnValue: 0, returnValueForMissingStub: 0);
  }

  @override
  int get totalBytes {
    return super.noSuchMethod(Invocation.getter(#totalBytes),
        returnValue: 0, returnValueForMissingStub: 0);
  }

  @override
  ReferencePlatform get ref {
    return super.noSuchMethod(Invocation.getter(#ref),
        returnValue: TestReferencePlatform(),
        returnValueForMissingStub: TestReferencePlatform());
  }

  @override
  TaskState get state {
    return super.noSuchMethod(Invocation.getter(#state),
        returnValue: TaskState.running,
        returnValueForMissingStub: TaskState.running);
  }
}

// Creates a test file with a specified name to
// a locally directory
Future<File> createFile(String name) async {
  final Directory systemTempDir = Directory.systemTemp;
  final File file = await File('${systemTempDir.path}/$name').create();
  await file.writeAsString(kTestString);
  return file;
}

Future<T> neverEndingFuture<T>() async {
  // ignore: literal_only_boolean_expressions
  while (true) {
    await Future.delayed(const Duration(minutes: 5));
  }
}
