// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage_platform_interface/firebase_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../mock.dart';

void main() {
  setupFirebaseStorageMocks();

  TestReferencePlatform referencePlatform;
  FirebaseApp app;
  FirebaseStoragePlatform firebaseStoragePlatform;

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
          ReferencePlatform.verifyExtends(referencePlatform);
          return;
        } catch (_) {
          fail('thrown an unexpected exception');
        }
      });

      test('throws an [AssertionError] exception when instance is null', () {
        expect(
            () => ReferencePlatform.verifyExtends(null), throwsAssertionError);
      });
    });

    test('get.bucket returns successfully', () async {
      final bucket = await referencePlatform.bucket;
      expect(bucket, isA<String>());
    });

    test('get.fullPath returns successfully', () async {
      final fullPath = await referencePlatform.fullPath;
      expect(fullPath, isA<String>());
    });

    test('get.name returns successfully', () async {
      final name = await referencePlatform.name;
      expect(name, isA<String>());
    });

    test('get.parent should throw unimplemented', () async {
      try {
        await referencePlatform.parent;
      } on UnimplementedError catch (e) {
        expect(e.message, equals('ref() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('get.root should throw unimplemented', () async {
      try {
        await referencePlatform.root;
      } on UnimplementedError catch (e) {
        expect(e.message, equals('ref() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('get.child should throw unimplemented', () async {
      try {
        await referencePlatform.child('/');
      } on UnimplementedError catch (e) {
        expect(e.message, equals('ref() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if delete()', () async {
      try {
        await referencePlatform.delete();
      } on UnimplementedError catch (e) {
        expect(e.message, equals('delete() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if getDownloadURL()', () async {
      try {
        await referencePlatform.getDownloadURL();
      } on UnimplementedError catch (e) {
        expect(e.message, equals('getDownloadURL() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if getMetadata()', () async {
      try {
        await referencePlatform.getMetadata();
      } on UnimplementedError catch (e) {
        expect(e.message, equals('getMetadata() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if list()', () async {
      try {
        await referencePlatform.list(ListOptions(maxResults: 10));
      } on UnimplementedError catch (e) {
        expect(e.message, equals('list() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if listAll()', () async {
      try {
        await referencePlatform.listAll();
      } on UnimplementedError catch (e) {
        expect(e.message, equals('listAll() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if putData()', () async {
      try {
        await referencePlatform.putData(null);
      } on UnimplementedError catch (e) {
        expect(e.message, equals('putData() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if putBlob()', () async {
      try {
        await referencePlatform.putBlob(null);
      } on UnimplementedError catch (e) {
        expect(e.message, equals('putBlob() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if putFile()', () async {
      try {
        await referencePlatform.putFile(null);
      } on UnimplementedError catch (e) {
        expect(e.message, equals('putFile() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if putString()', () async {
      try {
        await referencePlatform.putString('foo', PutStringFormat.base64);
      } on UnimplementedError catch (e) {
        expect(e.message, equals('putString() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if updateMetadata()', () async {
      try {
        await referencePlatform.updateMetadata(null);
      } on UnimplementedError catch (e) {
        expect(e.message, equals('updateMetadata() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if writeToFile()', () async {
      try {
        await referencePlatform.writeToFile(null);
      } on UnimplementedError catch (e) {
        expect(e.message, equals('writeToFile() is not implemented'));
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
  TestFirebaseStoragePlatform(FirebaseApp app, String bucket)
      : super(appInstance: app, bucket: bucket);
}
