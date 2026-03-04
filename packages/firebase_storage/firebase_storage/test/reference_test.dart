// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage_platform_interface/firebase_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'mock.dart';

MockReferencePlatform mockReference = MockReferencePlatform();
MockReferencePlatform mockJpgReference = MockReferencePlatform();
MockListResultPlatform mockListResultPlatform = MockListResultPlatform();
MockUploadTaskPlatform mockUploadTaskPlatform = MockUploadTaskPlatform();
MockDownloadTaskPlatform mockDownloadTaskPlatform = MockDownloadTaskPlatform();

Future<void> main() async {
  setupFirebaseStorageMocks();
  late FirebaseStorage storage;
  late Reference testRef;
  FullMetadata testFullMetadata = FullMetadata(testMetadataMap);
  ListOptions testListOptions =
      const ListOptions(maxResults: testMaxResults, pageToken: testPageToken);

  SettableMetadata testSettableMetadata = SettableMetadata();
  File testFile = await createFile('foo.txt');

  group('$Reference', () {
    setUpAll(() async {
      FirebaseStoragePlatform.instance = kMockStoragePlatform;

      await Firebase.initializeApp();
      storage = FirebaseStorage.instance;

      when(kMockStoragePlatform.ref(any)).thenReturn(mockReference);

      testRef = storage.ref();
    });

    group('.bucket', () {
      test('verify delegate method is called', () {
        when(mockReference.bucket).thenReturn(testBucket);

        final result = testRef.bucket;

        expect(result, isA<String>());
        expect(result, testBucket);
      });
    });

    group('.fullPath', () {
      test('verify delegate method is called', () {
        when(mockReference.fullPath).thenReturn(testFullPath);

        final result = testRef.fullPath;

        expect(result, isA<String>());
        expect(result, testFullPath);
      });
    });

    group('.name', () {
      test('verify delegate method is called', () {
        when(mockReference.name).thenReturn(testName);

        final result = testRef.name;

        expect(result, isA<String>());
        expect(result, testName);
      });
    });

    group('.parent', () {
      test('verify delegate method is called', () {
        when(mockReference.parent).thenReturn(mockReference);

        final result = testRef.parent;

        expect(result, isA<Reference>());
      });
      test('returns null if root', () {
        when(mockReference.parent).thenReturn(null);

        final result = testRef.parent;

        expect(result, isNull);
      });
    });

    group('.root', () {
      test('verify delegate method is called', () {
        when(mockReference.root).thenReturn(mockReference);

        final result = testRef.root;

        expect(result, isA<Reference>());

        verify(mockReference.root);
      });
    });

    group('child()', () {
      test('verify delegate method is called', () {
        when(mockReference.child(testFullPath)).thenReturn(mockReference);

        final result = testRef.child(testFullPath);

        expect(result, isA<Reference>());

        verify(mockReference.child(testFullPath));
      });
    });

    group('delete()', () {
      test('verify delegate method is called', () async {
        when(mockReference.delete()).thenAnswer((_) => Future.value());

        await testRef.delete();

        verify(mockReference.delete());
      });
    });

    group('getDownloadURL()', () {
      test('verify delegate method is called', () async {
        when(mockReference.getDownloadURL())
            .thenAnswer((_) => Future.value(testDownloadUrl));

        final result = await testRef.getDownloadURL();

        expect(result, isA<String>());
        expect(result, testDownloadUrl);

        verify(mockReference.getDownloadURL());
      });
    });

    group('getMetadata()', () {
      test('verify delegate method is called', () async {
        when(mockReference.getMetadata())
            .thenAnswer((_) => Future.value(testFullMetadata));

        final result = await testRef.getMetadata();

        expect(result, isA<FullMetadata>());
        expect(result.contentType, testMetadataMap['contentType']);

        verify(mockReference.getMetadata());
      });
    });

    group('list()', () {
      test('verify delegate method is called', () async {
        when(mockReference.list(testListOptions))
            .thenAnswer((_) => Future.value(mockListResultPlatform));
        final result = await testRef.list(testListOptions);

        expect(result, isA<ListResult>());

        verify(mockReference.list(testListOptions));
      });

      test('throws AssertionError if max results is not greater than 0', () {
        ListOptions listOptions =
            const ListOptions(maxResults: 0, pageToken: testPageToken);
        expect(() => testRef.list(listOptions), throwsAssertionError);
      });

      test('throws AssertionError if max results is greater than 1000', () {
        ListOptions listOptions =
            const ListOptions(maxResults: 1001, pageToken: testPageToken);

        expect(() => testRef.list(listOptions), throwsAssertionError);
      });
    });

    group('listAll()', () {
      test('verify delegate method is called', () async {
        when(mockReference.listAll())
            .thenAnswer((_) => Future.value(mockListResultPlatform));

        final result = await testRef.listAll();

        expect(result, isA<ListResult>());

        verify(mockReference.listAll());
      });
    });

    group('put()', () {
      test('verify delegate method is called', () {
        List<int> list = utf8.encode('hello world');

        Uint8List data = Uint8List.fromList(list);

        when(mockReference.putData(data)).thenReturn(mockUploadTaskPlatform);

        final result = testRef.putData(data);

        expect(result, isA<Task>());

        verify(mockReference.putData(data));
      });
    });

    group('putBlob()', () {
      test('verify delegate method is called', () {
        when(mockReference.putBlob(testFile))
            .thenReturn(mockUploadTaskPlatform);

        final result = testRef.putBlob(testFile);

        expect(result, isA<Task>());

        verify(mockReference.putBlob(testFile));
      });

      test('throws AssertionError if blob is null', () {
        expect(() => testRef.putBlob(null), throwsAssertionError);
      });
    });

    group('putFile()', () {
      test('verify delegate method is called', () {
        when(mockReference.putFile(testFile))
            .thenReturn(mockUploadTaskPlatform);

        final result = testRef.putFile(testFile);

        expect(result, isA<Task>());

        verify(mockReference.putFile(testFile));
      });

      test('throws AssertionError if file does not exists', () async {
        File file = await createFile('delete-me');
        file.deleteSync();

        expect(() => testRef.putFile(file), throwsAssertionError);
      });
    });

    group('putString()', () {
      test('raw string values', () {
        final result = testRef.putString(testString);

        expect(result, isA<Task>());

        // confirm raw string was converted to a Base64 format
        String data = base64.encode(utf8.encode(testString));
        verify(mockReference.putString(data, PutStringFormat.base64));
      });

      test('data_url format', () {
        UriData uriData = UriData.fromString(testString, base64: true);
        Uri uri = uriData.uri;
        final result =
            testRef.putString(uri.toString(), format: PutStringFormat.dataUrl);

        expect(result, isA<Task>());

        // confirm data_url was converted to a Base64 format
        UriData uriDataExpected = UriData.fromUri(Uri.parse(uri.toString()));
        verify(mockReference.putString(
            uriDataExpected.contentText, PutStringFormat.base64, any));
      });

      test('throws AssertionError if data_url is not a Base64 format', () {
        UriData uriData = UriData.fromString(testString);
        Uri uri = uriData.uri;
        expect(
            () => testRef.putString(uri.toString(),
                format: PutStringFormat.dataUrl),
            throwsAssertionError);
      });
    });

    group('updateMetadata()', () {
      test('verify delegate method is called', () async {
        when(mockReference.updateMetadata(testSettableMetadata))
            .thenAnswer((_) => Future.value(testFullMetadata));

        final result = await testRef.updateMetadata(testSettableMetadata);

        expect(result, isA<FullMetadata>());
        expect(result.contentType, 'gif');

        verify(mockReference.updateMetadata(testSettableMetadata));
      });
    });

    group('writeToFile()', () {
      test('verify delegate method is called', () {
        when(mockReference.writeToFile(testFile))
            .thenReturn(mockDownloadTaskPlatform);

        final result = testRef.writeToFile(testFile);

        expect(result, isA<Task>());

        verify(mockReference.writeToFile(testFile));
      });
    });

    group('putData() contentType inference', () {
      late Reference jpgRef;

      setUp(() {
        when(kMockStoragePlatform.ref(any)).thenReturn(mockJpgReference);
        when(mockJpgReference.bucket).thenReturn(testBucket);
        when(mockJpgReference.fullPath).thenReturn('foo/photo.jpg');
        when(mockJpgReference.name).thenReturn('photo.jpg');
        jpgRef = storage.ref('foo/photo.jpg');
      });

      test('infers contentType from ref name when no metadata', () {
        List<int> list = utf8.encode('hello');
        Uint8List data = Uint8List.fromList(list);
        when(mockJpgReference.putData(data, any))
            .thenReturn(mockUploadTaskPlatform);

        jpgRef.putData(data);

        final captured = verify(mockJpgReference.putData(data, captureAny))
            .captured
            .single as SettableMetadata;
        expect(captured.contentType, 'image/jpeg');
      });

      test('infers contentType when metadata has no contentType', () {
        List<int> list = utf8.encode('hello');
        Uint8List data = Uint8List.fromList(list);
        when(mockJpgReference.putData(data, any))
            .thenReturn(mockUploadTaskPlatform);

        jpgRef.putData(data, SettableMetadata(contentLanguage: 'en'));

        final captured = verify(mockJpgReference.putData(data, captureAny))
            .captured
            .single as SettableMetadata;
        expect(captured.contentType, 'image/jpeg');
        expect(captured.contentLanguage, 'en');
      });

      test('preserves explicit contentType', () {
        List<int> list = utf8.encode('hello');
        Uint8List data = Uint8List.fromList(list);
        when(mockJpgReference.putData(data, any))
            .thenReturn(mockUploadTaskPlatform);

        jpgRef.putData(
            data, SettableMetadata(contentType: 'application/octet-stream'));

        final captured = verify(mockJpgReference.putData(data, captureAny))
            .captured
            .single as SettableMetadata;
        expect(captured.contentType, 'application/octet-stream');
      });

      test('preserves customMetadata when inferring contentType', () {
        List<int> list = utf8.encode('hello');
        Uint8List data = Uint8List.fromList(list);
        when(mockJpgReference.putData(data, any))
            .thenReturn(mockUploadTaskPlatform);

        jpgRef.putData(
            data, SettableMetadata(customMetadata: {'activity': 'test'}));

        final captured = verify(mockJpgReference.putData(data, captureAny))
            .captured
            .single as SettableMetadata;
        expect(captured.contentType, 'image/jpeg');
        expect(captured.customMetadata, {'activity': 'test'});
      });

      test('no inference when ref has no extension', () {
        // Reset to the default mock with no extension
        when(kMockStoragePlatform.ref(any)).thenReturn(mockReference);
        when(mockReference.name).thenReturn(testName);
        final noExtRef = storage.ref();

        List<int> list = utf8.encode('hello');
        Uint8List data = Uint8List.fromList(list);
        when(mockReference.putData(data)).thenReturn(mockUploadTaskPlatform);

        noExtRef.putData(data);

        verify(mockReference.putData(data));
      });
    });

    group('putBlob() contentType inference', () {
      late Reference jpgRef;

      setUp(() {
        when(kMockStoragePlatform.ref(any)).thenReturn(mockJpgReference);
        when(mockJpgReference.bucket).thenReturn(testBucket);
        when(mockJpgReference.fullPath).thenReturn('foo/photo.jpg');
        when(mockJpgReference.name).thenReturn('photo.jpg');
        jpgRef = storage.ref('foo/photo.jpg');
      });

      test('infers contentType from ref name when no metadata', () {
        when(mockJpgReference.putBlob(any, any))
            .thenReturn(mockUploadTaskPlatform);

        jpgRef.putBlob('blob-data');

        final captured = verify(mockJpgReference.putBlob(any, captureAny))
            .captured
            .single as SettableMetadata;
        expect(captured.contentType, 'image/jpeg');
      });

      test('preserves explicit contentType', () {
        when(mockJpgReference.putBlob(any, any))
            .thenReturn(mockUploadTaskPlatform);

        jpgRef.putBlob(
            'blob-data', SettableMetadata(contentType: 'text/plain'));

        final captured = verify(mockJpgReference.putBlob(any, captureAny))
            .captured
            .single as SettableMetadata;
        expect(captured.contentType, 'text/plain');
      });
    });

    test('hashCode()', () {
      expect(testRef.hashCode, Object.hash(storage, testFullPath));
    });

    test('toString()', () {
      expect(
        testRef.toString(),
        '$Reference(app: $defaultFirebaseAppName, fullPath: $testFullPath)',
      );
    });
  });
}
