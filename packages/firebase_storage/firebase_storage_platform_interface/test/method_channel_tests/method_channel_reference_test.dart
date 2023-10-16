// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage_platform_interface/firebase_storage_platform_interface.dart';
import 'package:firebase_storage_platform_interface/src/method_channel/method_channel_firebase_storage.dart';
import 'package:firebase_storage_platform_interface/src/method_channel/method_channel_reference.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mock.dart';

void main() {
  setupFirebaseStorageMocks();

  late FirebaseStoragePlatform storage;
  late ReferencePlatform ref;
  final List<MethodCall> log = <MethodCall>[];
  const String bucketParam = 'bucket-test';

  final kMetadata = SettableMetadata(
      contentLanguage: 'en',
      customMetadata: <String, String>{'activity': 'test'});
  const kListOptions = ListOptions(maxResults: 20);

  group('$MethodChannelReference', () {
    setUpAll(() async {
      FirebaseApp app = await Firebase.initializeApp();

      storage = MethodChannelFirebaseStorage(app: app, bucket: bucketParam);
      ref = MethodChannelReference(storage, '/');
    });

    setUp(() async {
      log.clear();
    });

    group('constructor', () {
      test('should create an instance', () {
        MethodChannelReference test = MethodChannelReference(storage, '/');
        expect(test, isInstanceOf<ReferencePlatform>());
      });
    });

    group('delete', () {
      test(
          'catch a [PlatformException] error and throws a [FirebaseException] error',
          () async {
        Function callMethod;
        callMethod = () => ref.delete();
        await testExceptionHandling('PLATFORM', callMethod);
      });
    });

    group('getDownloadURL', () {
      test(
          'catch a [PlatformException] error and throws a [FirebaseException] error',
          () async {
        Function callMethod;
        callMethod = () => ref.getDownloadURL();
        await testExceptionHandling('PLATFORM', callMethod);
      });
    });

    group('getMetadata', () {
      test(
          'catch a [PlatformException] error and throws a [FirebaseStorageException] error',
          () async {
        Function callMethod;
        callMethod = () => ref.getMetadata();
        await testExceptionHandling('PLATFORM', callMethod);
      });
    });

    group('list', () {
      test(
          'catch a [PlatformException] error and throws a [FirebaseStorageException] error',
          () async {
        Function callMethod;
        callMethod = () => ref.list(kListOptions);
        await testExceptionHandling('PLATFORM', callMethod);
      });
    });

    group('listAll', () {
      test(
          'catch a [PlatformException] error and throws a [FirebaseStorageException] error',
          () async {
        Function callMethod;
        callMethod = () => ref.listAll();
        await testExceptionHandling('PLATFORM', callMethod);
      });
    });

    group('putBlob', () {
      List<int> list = utf8.encode('hello world');
      ByteBuffer buffer = Uint8List.fromList(list).buffer;

      test('should throw [UnimplementedError]', () async {
        expect(() => ref.putBlob(buffer, kMetadata), throwsUnimplementedError);
      });
    });

    group('updateMetadata', () {
      test(
          'catch a [PlatformException] error and throws a [FirebaseException] error',
          () async {
        Function callMethod;
        callMethod = () => ref.updateMetadata(kMetadata);
        await testExceptionHandling('PLATFORM', callMethod);
      });
    });
  });
}
