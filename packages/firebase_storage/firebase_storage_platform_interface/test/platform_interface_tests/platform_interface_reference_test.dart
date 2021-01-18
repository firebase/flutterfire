// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: avoid_catching_errors

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage_platform_interface/firebase_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../mock.dart';

void main() {
  setupFirebaseStorageMocks();

  TestReferencePlatform? referencePlatform;
  FirebaseApp? app;
  FirebaseStoragePlatform? firebaseStoragePlatform;

  group('$ReferencePlatform()', () {
    setUpAll(() async {
      app = await Firebase.initializeApp();
      firebaseStoragePlatform = TestFirebaseStoragePlatform(app, 'foo');
      referencePlatform =
          TestReferencePlatform(firebaseStoragePlatform, '/foo');
    });

    test('Constructor', () {
      expect(referencePlatform, isA<ReferencePlatform>());
      expect(referencePlatform, isA<PlatformInterface>());
    });

    group('verifyExtends()', () {
      test('calls successfully', () {
        try {
          ReferencePlatform.verifyExtends(referencePlatform!);
          return;
        } catch (_) {
          fail('thrown an unexpected exception');
        }
      });
    });

    test('get.bucket returns successfully', () async {
      final bucket = referencePlatform!.bucket;
      expect(bucket, isA<String>());
    });

    test('get.fullPath returns successfully', () async {
      final fullPath = referencePlatform!.fullPath;
      expect(fullPath, isA<String>());
    });

    test('get.name returns successfully', () async {
      final name = referencePlatform!.name;
      expect(name, isA<String>());
    });

    test('get.parent should throw unimplemented', () async {
      try {
        referencePlatform!.parent;
      } on UnimplementedError catch (e) {
        expect(e.message, equals('ref() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('get.root should throw unimplemented', () async {
      try {
        referencePlatform!.root;
      } on UnimplementedError catch (e) {
        expect(e.message, equals('ref() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('get.child should throw unimplemented', () async {
      try {
        referencePlatform!.child('/');
      } on UnimplementedError catch (e) {
        expect(e.message, equals('ref() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if delete()', () async {
      try {
        await referencePlatform!.delete();
      } on UnimplementedError catch (e) {
        expect(e.message, equals('delete() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if getDownloadURL()', () async {
      try {
        await referencePlatform!.getDownloadURL();
      } on UnimplementedError catch (e) {
        expect(e.message, equals('getDownloadURL() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if getMetadata()', () async {
      try {
        await referencePlatform!.getMetadata();
      } on UnimplementedError catch (e) {
        expect(e.message, equals('getMetadata() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if list()', () async {
      try {
        await referencePlatform!.list(const ListOptions(maxResults: 10));
      } on UnimplementedError catch (e) {
        expect(e.message, equals('list() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if listAll()', () async {
      try {
        await referencePlatform!.listAll();
      } on UnimplementedError catch (e) {
        expect(e.message, equals('listAll() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if putBlob()', () async {
      try {
        referencePlatform!.putBlob(null);
      } on UnimplementedError catch (e) {
        expect(e.message, equals('putBlob() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if putString()', () async {
      try {
        referencePlatform!.putString('foo', PutStringFormat.base64);
      } on UnimplementedError catch (e) {
        expect(e.message, equals('putString() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });
  });
}

class TestReferencePlatform extends ReferencePlatform {
  TestReferencePlatform(storage, path) : super(storage, path);
}

class TestFirebaseStoragePlatform extends FirebaseStoragePlatform {
  TestFirebaseStoragePlatform(FirebaseApp? app, String bucket)
      : super(appInstance: app, bucket: bucket);
}
