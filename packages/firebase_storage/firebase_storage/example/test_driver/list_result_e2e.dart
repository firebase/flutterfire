import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void runListResultTests() {
  group('$ListResult', () {
    FirebaseStorage storage;
    ListResult result;
    setUpAll(() async {
      storage = FirebaseStorage.instance;
      Reference ref = storage.ref('/');
      result = await ref.list(ListOptions(maxResults: 1));
    });

    test('items', () async {
      expect(result.items.length, greaterThan(0));
      expect(result.prefixes, isA<List<Reference>>());
      expect(result.prefixes.length, greaterThan(0));
    });

    test('nextPageToken', () async {
      expect(result.nextPageToken, isNotNull);
    });

    test('prefixes', () async {
      expect(result.items.length, greaterThan(0));
      expect(result.prefixes, isA<List<Reference>>());
      expect(result.prefixes.length, greaterThan(0));
    });
  });
}
