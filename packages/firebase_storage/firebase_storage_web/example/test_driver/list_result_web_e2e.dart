// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_storage_platform_interface/firebase_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:firebase_storage_web/src/list_result_web.dart';
import 'package:mockito/mockito.dart';

import 'mocks/mocks.dart';

void runListResultTests() {
  group('ListResultWeb', () {
    MockStorageWeb storage;

    setUp(() {
      storage = MockStorageWeb();
    });

    test('constructor', () {
      final listResult = ListResultWeb(storage);
      expect(listResult, isA<ListResultPlatform>());
    });

    test('stores the nextPageToken', () {
      final listResult =
          ListResultWeb(storage, nextPageToken: 'next-page-token');
      expect(listResult.nextPageToken, 'next-page-token');
    });

    group('items', () {
      final itemsList = ['item-1', 'item-2'];

      test('null items -> empty list of references', () {
        final listResult = ListResultWeb(storage);
        final items = listResult.items;
        expect(items, isNotNull);
        expect(items, isEmpty);
      });

      test('converts items through the storage', () {
        final listResult = ListResultWeb(
          storage,
          items: itemsList,
        );
        final items = listResult.items;
        expect(items.length, 2);
        itemsList.forEach((ref) {
          verify(storage.ref(ref));
        });
      });
    });

    group('prefixes', () {
      final prefixesList = ['item-1', 'item-2'];

      test('null prefixes -> empty list of references', () {
        final listResult = ListResultWeb(storage);
        final prefixes = listResult.prefixes;
        expect(prefixes, isNotNull);
        expect(prefixes, isEmpty);
      });

      test('converts prefixes through the storage', () {
        final listResult = ListResultWeb(
          storage,
          prefixes: prefixesList,
        );
        final prefixes = listResult.prefixes;
        expect(prefixes.length, 2);
        prefixesList.forEach((ref) {
          verify(storage.ref(ref));
        });
      });
    });
  });
}
