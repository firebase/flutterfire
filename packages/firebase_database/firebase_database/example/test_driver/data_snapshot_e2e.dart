import 'package:flutter_test/flutter_test.dart';

import 'firebase_database_e2e.dart';

void runDataSnapshotTests() {
  group('DataSnapshot', () {
    setUp(() async {
      await database.ref('flutterfire').set(0);
    });

    test('supports null childKeys for maps', () async {
      // Regression test for https://github.com/FirebaseExtended/flutterfire/issues/6002

      final ref = database.ref('flutterfire');

      final transactionResult = await ref.runTransaction((_) {
        return {'v': 'vala'};
      });

      expect(transactionResult.committed, true);
      expect(transactionResult.dataSnapshot!.value, {'v': 'vala'});
    });

    test('#key returns correct key', () async {
      final s = await database.ref('flutterfire').get();
      expect(s.key, 'flutterfire');
    });

    test('hasChildren is true if snapshot has children', () async {
      final s = await database.ref('ordered').get();
      expect(s.hasChildren, true);
    });

    test("hasChildren is false if snapshot doesn't have children", () async {
      final s = await database.ref('flutterfire').get();
      expect(s.hasChildren, false);
    });

    test('numChildren returns a correct number of children', () async {
      final os = await database.ref('ordered').get();
      final fs = await database.ref('flutterfire').get();

      expect(os.numChildren, 4);
      expect(fs.numChildren, 0);
    });

    test(
      'hasChild(String path) returns true if snapshot has a non-null child at a given path',
      () async {
        final s = await database.ref('list-values').get();
        expect(s.hasChild('list/0'), true);
        expect(s.hasChild('list/1'), true);
      },
    );

    test(
      'hasChild(String path) returns false if snapshot has a non-null child at a given path',
      () async {
        final s = await database.ref('list-values').get();
        expect(s.hasChild('list/2'), false);
        expect(s.hasChild('non-existing-child'), false);
      },
    );

    test('forEach iterates over children in a correct order', () async {
      final ref = database.ref('priority_test');

      await Future.wait([
        ref.child('first').set(42),
        ref.child('second').set(15),
        ref.child('third').set(18),
      ]);

      final s = await ref.orderByValue().get();
      final keys = [];

      s.forEach((snapshot) {
        keys.add(snapshot.key);
      });

      expect(keys, ['second', 'third', 'first']);
    });
  });

  group('DataSnapshot.exists', () {
    test('false for no data', () async {
      final databaseRef = database.ref('a-non-existing-reference');
      final dataSnapshot = await databaseRef.get();

      expect(dataSnapshot.exists, false);
    });

    test('true for existing data', () async {
      final databaseRef = database.ref('ordered/one');
      final dataSnapshot = await databaseRef.get();

      expect(dataSnapshot.exists, true);
    });
  });
}
