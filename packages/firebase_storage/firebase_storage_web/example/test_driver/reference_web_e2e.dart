import 'dart:typed_data';

import 'package:firebase/firebase.dart' as fb;

import 'package:firebase_storage_platform_interface/firebase_storage_platform_interface.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:firebase_storage_web/src/reference_web.dart';
import 'package:mockito/mockito.dart';

import 'mocks/mocks.dart';

void runReferenceTests() {
  group('ReferenceWeb', () {
    MockStorageWeb storage;
    MockFbStorage fbStorage;

    setUp(() {
      storage = MockStorageWeb();
      fbStorage = MockFbStorage();
      when(storage.fbStorage).thenReturn(fbStorage);
    });

    group('Constructor', () {
      test('builds internal _ref from URL (https):', () {
        ReferenceWeb(storage, 'https://some-https-url');

        verify(fbStorage.refFromURL('https://some-https-url'));
        verifyNever(fbStorage.ref(any));
      });

      test('builds internal _ref from URL (gs):', () {
        ReferenceWeb(storage, 'gs://some-url');

        verify(fbStorage.refFromURL('gs://some-url'));
        verifyNever(fbStorage.ref(any));
      });

      test('builds internal _ref from a relative path:', () {
        ReferenceWeb(storage, 'some/relative/path.txt');

        verify(fbStorage.ref('some/relative/path.txt'));
        verifyNever(fbStorage.refFromURL(any));
      });
    });

    group('Forwards calls to _ref: ', () {
      MockRef ref;

      ReferenceWeb reference;
      setUp(() {
        ref = MockRef();
        when(fbStorage.ref(any)).thenReturn(ref);

        reference = ReferenceWeb(storage, 'some/random/path.txt');
      });

      test('delete', () {
        reference.delete();
        verify(ref.delete());
      });

      test('getDownloadURL', () async {
        when(ref.getDownloadURL())
            .thenAnswer((_) async => Uri.parse('https://some-url'));

        final url = await reference.getDownloadURL();

        expect(url, 'https://some-url');
      });

      test('getMetadata', () async {
        final mockMetadata = MockFullMetadata();
        when(mockMetadata.bucket).thenReturn('some-test-bucket-from-fake');
        when(mockMetadata.updated).thenReturn(DateTime.now());
        when(mockMetadata.timeCreated)
            .thenReturn(DateTime.now().subtract(Duration(seconds: 10)));

        when(ref.getMetadata()).thenAnswer((_) async => mockMetadata);

        final metadata = await reference.getMetadata();

        expect(metadata.bucket, 'some-test-bucket-from-fake');
      });

      test('listAll', () async {
        final mockListResults = MockListResults();
        when(mockListResults.nextPageToken).thenReturn('next-page-token');
        // Not bothering with items/prefixes, because storage is mocked too...

        when(ref.listAll()).thenAnswer((_) async => mockListResults);

        final listResults = await reference.listAll();

        expect(listResults.nextPageToken, 'next-page-token');
      });

      test('list', () async {
        final mockListResults = MockListResults();
        when(mockListResults.nextPageToken).thenReturn('next-page-token');

        when(ref.list(captureAny)).thenAnswer((_) async => mockListResults);

        final listResults = await reference.list(ListOptions(
          maxResults: 10,
          pageToken: 'previous-page-token',
        ));

        expect(listResults.nextPageToken, 'next-page-token');

        fb.ListOptions captured = verify(ref.list(captureAny)).captured.first;

        expect(captured.maxResults, 10);
        expect(captured.pageToken, 'previous-page-token');
      });

      group('getData', () {
        MockFullMetadata mockMetadata;

        setUp(() {
          mockMetadata = MockFullMetadata();
          when(mockMetadata.updated).thenReturn(DateTime.now());
          when(mockMetadata.timeCreated)
              .thenReturn(DateTime.now().subtract(Duration(seconds: 10)));

          when(ref.getDownloadURL())
              .thenAnswer((_) async => Uri.parse('https://some-url'));
          when(ref.getMetadata()).thenAnswer((_) async => mockMetadata);
        });

        test('file is too large', () async {
          when(mockMetadata.size).thenReturn(1024);

          Function readBytes = (dynamic url) async {
            fail('The file should not be downloaded!');
          };

          final data = await reference.getData(128, readBytes: readBytes);

          expect(data, isNull);
        });

        test('file is not too large', () async {
          when(mockMetadata.size).thenReturn(13);

          Function readBytes = (dynamic url) async {
            expect(url, 'https://some-url');

            return Uint8List.fromList('hello, world!'.codeUnits);
          };

          final data = await reference.getData(256, readBytes: readBytes);

          expect(String.fromCharCodes(data), 'hello, world!');
        });

        test('file size does not matter', () async {
          Function readBytes = (dynamic url) async {
            return Uint8List.fromList('hello, world!'.codeUnits);
          };

          final data = await reference.getData(0, readBytes: readBytes);

          expect(String.fromCharCodes(data), 'hello, world!');
          verifyNever(ref.getMetadata());
        });
      });

    });
  });
}
