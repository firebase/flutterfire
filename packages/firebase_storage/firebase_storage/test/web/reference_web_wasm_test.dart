// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('browser')
library;

import 'dart:io' as io;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage_platform_interface/firebase_storage_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class _FakeFirebasePlatform extends FirebasePlatform {
  @override
  FirebaseAppPlatform app([String name = defaultFirebaseAppName]) {
    return _FakeFirebaseAppPlatform(
      name,
      const FirebaseOptions(
        apiKey: 'apiKey',
        appId: 'appId',
        messagingSenderId: 'messagingSenderId',
        projectId: 'projectId',
        storageBucket: 'gs://test-bucket',
      ),
    );
  }
}

class _FakeFirebaseAppPlatform extends FirebaseAppPlatform {
  _FakeFirebaseAppPlatform(super.name, super.options);
}

class _FakeStoragePlatform extends FirebaseStoragePlatform
    with MockPlatformInterfaceMixin {
  _FakeStoragePlatform({super.appInstance, required super.bucket});

  @override
  FirebaseStoragePlatform delegateFor({
    FirebaseApp? app,
    required String bucket,
  }) => _FakeStoragePlatform(appInstance: app, bucket: bucket);

  @override
  ReferencePlatform ref(String path) => _FakeReferencePlatform(this, path);
}

class _FakeReferencePlatform extends ReferencePlatform
    with MockPlatformInterfaceMixin {
  _FakeReferencePlatform(super.storage, super.path);
}

void main() {
  setUpAll(() {
    FirebasePlatform.instance = _FakeFirebasePlatform();
    FirebaseStoragePlatform.instance = _FakeStoragePlatform(
      bucket: 'gs://test-bucket',
    );
  });

  test('putFile and writeToFile compile with dart:io File and throw on web', () {
    final ref = FirebaseStorage.instance.ref('test/file.txt');

    // Verify standard guarded cross-platform caller code compiles on JS & Wasm.
    if (!kIsWeb) {
      ref.putFile(io.File('file.txt'));
      ref.writeToFile(io.File('file.txt'));
    }

    // Also verify tear-offs parameterized on dart:io File compile.
    final UploadTask Function(io.File) putTearOff = ref.putFile;
    final DownloadTask Function(io.File) writeTearOff = ref.writeToFile;
    expect(putTearOff, isNotNull);
    expect(writeTearOff, isNotNull);

    expect(() => ref.putFile(io.File('file.txt')), throwsUnimplementedError);
    expect(
      () => ref.writeToFile(io.File('file.txt')),
      throwsUnimplementedError,
    );
  });
}
