// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void setupListResultTests() {
  group('$ListResult', () {
    late FirebaseStorage storage;
    late ListResult result;

    setUpAll(() async {
      storage = FirebaseStorage.instance;
      Reference ref = storage.ref('flutter-tests/list');
      // Needs to be > half of the # of items in the storage,
      // so there's a chance of picking up some items and some
      // prefixes.
      result = await ref.list(const ListOptions(maxResults: 3));
    });

    test('items', () async {
      expect(result.items, isA<List<Reference>>());
      expect(result.items.length, greaterThan(0));
    });

    test('nextPageToken', () async {
      expect(result.nextPageToken, isNotNull);
    });

    test('prefixes', () async {
      expect(result.prefixes, isA<List<Reference>>());
      expect(result.prefixes.length, greaterThan(0));
    });
  });
}
