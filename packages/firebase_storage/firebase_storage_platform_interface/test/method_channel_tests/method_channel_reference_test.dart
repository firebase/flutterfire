// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';
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

  FirebaseStoragePlatform? storage;
  ReferencePlatform? ref;
  final List<MethodCall> log = <MethodCall>[];
  const String bucketParam = 'bucket-test';
  // mock props
  bool mockPlatformExceptionThrown = false;
  File? kFile;
  final kMetadata = SettableMetadata(
      contentLanguage: 'en',
      customMetadata: <String, String>{'activity': 'test'});
  const kListOptions = ListOptions(maxResults: 20);

  group('$MethodChannelReference', () {
    setUpAll(() async {
      FirebaseApp app = await Firebase.initializeApp();
      kFile = File('flt-ok.txt');

      handleMethodCall((call) async {
        log.add(call);
        if (mockPlatformExceptionThrown) {
          throw PlatformException(
              code: 'UNKNOWN', message: 'Mock platform exception thrown');
        }

        switch (call.method) {
          case 'Reference#getDownloadURL':
            return {'downloadURL': 'https://test-url.com/'};
          case 'Reference#list':
            return {
              'nextPageToken': '',
              'items': ['foo', 'bar'],
              'prefixes': ['foo', 'bar'],
            };
          case 'Reference#listAll':
            return {
              'nextPageToken': '',
              'items': ['foo', 'bar'],
              'prefixes': ['foo', 'bar'],
            };
          case 'Reference#getMetadata':
            return {};
          case 'Reference#updateMetadata':
            return {};
          case 'Task#startPutFile':
            return {};
          default:
            return null;
        }
      });

      storage = MethodChannelFirebaseStorage(app: app, bucket: bucketParam);
      ref = MethodChannelReference(storage!, '/');
    });

    setUp(() async {
      mockPlatformExceptionThrown = false;
      log.clear();
    });

    group('constructor', () {
      test('should create an instance', () {
        MethodChannelReference test = MethodChannelReference(storage!, '/');
        expect(test, isInstanceOf<ReferencePlatform>());
      });
    });

    group('delete', () {
      test('should invoke native method with correct args', () async {
        await ref!.delete();

        // check native method was called
        expect(log, <Matcher>[
          isMethodCall(
            'Reference#delete',
            arguments: <String, dynamic>{
              'appName': '[DEFAULT]',
              'maxOperationRetryTime': storage!.maxOperationRetryTime,
              'maxUploadRetryTime': storage!.maxUploadRetryTime,
              'maxDownloadRetryTime': storage!.maxDownloadRetryTime,
              'bucket': bucketParam,
              'path': '/',
            },
          ),
        ]);
      });

      test(
          'catch a [PlatformException] error and throws a [FirebaseException] error',
          () async {
        mockPlatformExceptionThrown = true;
        Function callMethod;
        callMethod = () => ref!.delete();
        await testExceptionHandling('PLATFORM', callMethod);
      });
    });

    group('getDownloadURL', () {
      test('should invoke native method with correct args', () async {
        await ref!.getDownloadURL();

        // check native method was called
        expect(log, <Matcher>[
          isMethodCall(
            'Reference#getDownloadURL',
            arguments: <String, dynamic>{
              'appName': '[DEFAULT]',
              'maxOperationRetryTime': storage!.maxOperationRetryTime,
              'maxUploadRetryTime': storage!.maxUploadRetryTime,
              'maxDownloadRetryTime': storage!.maxDownloadRetryTime,
              'bucket': bucketParam,
              'path': '/',
            },
          ),
        ]);
      });

      test(
          'catch a [PlatformException] error and throws a [FirebaseException] error',
          () async {
        mockPlatformExceptionThrown = true;
        Function callMethod;
        callMethod = () => ref!.getDownloadURL();
        await testExceptionHandling('PLATFORM', callMethod);
      });
    });

    group('getMetadata', () {
      test('should invoke native method with correct args', () async {
        await ref!.getMetadata();

        // check native method was called
        expect(log, <Matcher>[
          isMethodCall(
            'Reference#getMetadata',
            arguments: <String, dynamic>{
              'appName': '[DEFAULT]',
              'maxOperationRetryTime': storage!.maxOperationRetryTime,
              'maxUploadRetryTime': storage!.maxUploadRetryTime,
              'maxDownloadRetryTime': storage!.maxDownloadRetryTime,
              'bucket': bucketParam,
              'path': '/',
            },
          ),
        ]);
      });

      test(
          'catch a [PlatformException] error and throws a [FirebaseStorageException] error',
          () async {
        mockPlatformExceptionThrown = true;
        Function callMethod;
        callMethod = () => ref!.getMetadata();
        await testExceptionHandling('PLATFORM', callMethod);
      });
    });

    group('list', () {
      test('should invoke native method with correct args', () async {
        await ref!.list(kListOptions);

        // check native method was called
        expect(log, <Matcher>[
          isMethodCall(
            'Reference#list',
            arguments: <String, dynamic>{
              'appName': '[DEFAULT]',
              'maxOperationRetryTime': storage!.maxOperationRetryTime,
              'maxUploadRetryTime': storage!.maxUploadRetryTime,
              'maxDownloadRetryTime': storage!.maxDownloadRetryTime,
              'bucket': bucketParam,
              'path': '/',
              'options': <String, dynamic>{
                'maxResults': 20,
                'pageToken': null,
              }
            },
          ),
        ]);
      });

      test(
          'catch a [PlatformException] error and throws a [FirebaseStorageException] error',
          () async {
        mockPlatformExceptionThrown = true;
        Function callMethod;
        callMethod = () => ref!.list(kListOptions);
        await testExceptionHandling('PLATFORM', callMethod);
      });
    });

    group('listAll', () {
      test('should invoke native method with correct args', () async {
        await ref!.listAll();

        // check native method was called
        expect(log, <Matcher>[
          isMethodCall(
            'Reference#listAll',
            arguments: <String, dynamic>{
              'appName': '[DEFAULT]',
              'maxOperationRetryTime': storage!.maxOperationRetryTime,
              'maxUploadRetryTime': storage!.maxUploadRetryTime,
              'maxDownloadRetryTime': storage!.maxDownloadRetryTime,
              'bucket': bucketParam,
              'path': '/',
            },
          ),
        ]);
      });

      test(
          'catch a [PlatformException] error and throws a [FirebaseStorageException] error',
          () async {
        mockPlatformExceptionThrown = true;
        Function callMethod;
        callMethod = () => ref!.listAll();
        await testExceptionHandling('PLATFORM', callMethod);
      });
    });

    group('put', () {
      List<int> list = utf8.encode('hello world');
      Uint8List data = Uint8List.fromList(list);

      test('should invoke native method with correct args', () async {
        int handle = nextMockHandleId;
        ref!.putData(data, kMetadata);

        // check native method was called
        expect(log, <Matcher>[
          isMethodCall(
            'Task#startPutData',
            arguments: <String, dynamic>{
              'appName': '[DEFAULT]',
              'maxOperationRetryTime': storage!.maxOperationRetryTime,
              'maxUploadRetryTime': storage!.maxUploadRetryTime,
              'maxDownloadRetryTime': storage!.maxDownloadRetryTime,
              'bucket': bucketParam,
              'path': '/',
              'handle': handle,
              'data': list,
              'metadata': {
                'cacheControl': null,
                'contentDisposition': null,
                'contentEncoding': null,
                'contentLanguage': 'en',
                'contentType': null,
                'customMetadata': {'activity': 'test'}
              }
            },
          ),
        ]);
      });
    });

    group('putBlob', () {
      List<int> list = utf8.encode('hello world');
      ByteBuffer buffer = Uint8List.fromList(list).buffer;

      test('should throw [UnimplementedError]', () async {
        expect(() => ref!.putBlob(buffer, kMetadata), throwsUnimplementedError);
      });
    });

    group('putFile', () {
      test('should invoke native method with correct args', () async {
        int handle = nextMockHandleId;
        ref!.putFile(kFile!, kMetadata);

        // check native method was called
        expect(log, <Matcher>[
          isMethodCall(
            'Task#startPutFile',
            arguments: <String, dynamic>{
              'appName': '[DEFAULT]',
              'maxOperationRetryTime': storage!.maxOperationRetryTime,
              'maxUploadRetryTime': storage!.maxUploadRetryTime,
              'maxDownloadRetryTime': storage!.maxDownloadRetryTime,
              'bucket': bucketParam,
              'path': '/',
              'handle': handle,
              'filePath': kFile!.absolute.path,
              'metadata': {
                'cacheControl': null,
                'contentDisposition': null,
                'contentEncoding': null,
                'contentLanguage': 'en',
                'contentType': null,
                'customMetadata': {'activity': 'test'}
              }
            },
          ),
        ]);
      });
    });

    group('putString', () {
      test('should invoke native method with correct args', () async {
        const String data = 'foo';
        int handle = nextMockHandleId;
        ref!.putString(data, PutStringFormat.raw, kMetadata);

        // check native method was called
        expect(log, <Matcher>[
          isMethodCall(
            'Task#startPutString',
            arguments: <String, dynamic>{
              'appName': '[DEFAULT]',
              'maxOperationRetryTime': storage!.maxOperationRetryTime,
              'maxUploadRetryTime': storage!.maxUploadRetryTime,
              'maxDownloadRetryTime': storage!.maxDownloadRetryTime,
              'bucket': bucketParam,
              'path': '/',
              'handle': handle,
              'data': data,
              'format': PutStringFormat.raw.index,
              'metadata': {
                'cacheControl': null,
                'contentDisposition': null,
                'contentEncoding': null,
                'contentLanguage': 'en',
                'contentType': null,
                'customMetadata': {'activity': 'test'}
              }
            },
          ),
        ]);
      });
    });

    group('updateMetadata', () {
      test('should update successfully', () async {
        final fullMetadata = await ref!.updateMetadata(kMetadata);
        expect(fullMetadata, isInstanceOf<FullMetadata>());
      });

      test(
          'catch a [PlatformException] error and throws a [FirebaseException] error',
          () async {
        mockPlatformExceptionThrown = true;
        Function callMethod;
        callMethod = () => ref!.updateMetadata(kMetadata);
        await testExceptionHandling('PLATFORM', callMethod);
      });
    });

    group('writeToFile', () {
      test('should invoke native method with correct args', () async {
        int handle = nextMockHandleId;
        ref!.writeToFile(kFile!);

        // check native method was called
        expect(log, <Matcher>[
          isMethodCall(
            'Task#writeToFile',
            arguments: <String, dynamic>{
              'appName': '[DEFAULT]',
              'maxOperationRetryTime': storage!.maxOperationRetryTime,
              'maxUploadRetryTime': storage!.maxUploadRetryTime,
              'maxDownloadRetryTime': storage!.maxDownloadRetryTime,
              'bucket': bucketParam,
              'path': '/',
              'handle': handle,
              'filePath': kFile!.path,
            },
          ),
        ]);
      });
    });
  });
}
