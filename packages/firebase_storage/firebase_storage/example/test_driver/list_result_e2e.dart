// @dart = 2.9

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void runListResultTests() {
  group('$ListResult', () {
    /*late*/ FirebaseStorage storage;
    /*late*/ ListResult result;

    setUpAll(() async {
      storage = FirebaseStorage.instance;
      Reference ref = storage.ref('/list');
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
