// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage_platform_interface/firebase_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'mock.dart';

void main() {
  setupFirebaseStorageMocks();

  const String kNextPageToken = 'next-page-token';

  late FirebaseStorage storage;
  late ListResult listResult;
  MockReferencePlatform mockReference = MockReferencePlatform();
  MockListResultPlatform mockList = MockListResultPlatform();

  List<MockReferencePlatform> items =
      List.from([MockReferencePlatform(), MockReferencePlatform()]);
  List<MockReferencePlatform> prefixes =
      List.from([MockReferencePlatform(), MockReferencePlatform()]);

  group('$ListResult', () {
    setUpAll(() async {
      FirebaseStoragePlatform.instance = kMockStoragePlatform;

      await Firebase.initializeApp();
      storage = FirebaseStorage.instance;

      when(kMockStoragePlatform.ref(any)).thenReturn(mockReference);
      when(mockReference.list(any)).thenAnswer((_) => Future.value(mockList));
      when(mockList.items).thenReturn(items);
      when(mockList.nextPageToken).thenReturn(kNextPageToken);
      when(mockList.prefixes).thenReturn(prefixes);

      Reference ref = storage.ref();
      listResult =
          await ref.list(const ListOptions(maxResults: 10, pageToken: 'token'));
    });

    group('.items', () {
      test('verify delegate method is called', () {
        final items = listResult.items;
        expect(items, isA<List<Reference>>());
        expect(items.length, items.length);

        final item = items[0];
        expect(item, isA<Reference>());

        final item2 = items[1];
        expect(item2, isA<Reference>());

        verify(mockList.items);
      });
    });

    group('.nextPageToken', () {
      test('verify delegate method is called', () {
        final nextPageToken = listResult.nextPageToken;
        expect(nextPageToken, isA<String>());
        expect(nextPageToken, kNextPageToken);

        verify(mockList.nextPageToken);
      });
    });

    group('.prefixes', () {
      test('verify delegate method is called', () {
        final prefixes = listResult.prefixes;
        expect(prefixes, isA<List<Reference>>());
        expect(prefixes.length, prefixes.length);

        final prefix = prefixes[0];
        expect(prefix, isA<Reference>());

        verify(mockList.prefixes);
      });
    });
  });
}
