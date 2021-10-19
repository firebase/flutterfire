import 'package:flutter_test/flutter_test.dart';

import 'firebase_database_e2e.dart';

void runDataSnapshotTests() {
  group('DataSnapshot', () {
    test('supports null childKeys for maps', () async {
      // Regression test for https://github.com/FirebaseExtended/flutterfire/issues/6002

      final ref = database.ref('flutterfire');

      final transactionResult = await ref.runTransaction((_) {
        return {'v': 'vala'};
      });

      expect(transactionResult.committed, true);
      expect(transactionResult.dataSnapshot!.value, {'v': 'vala'});
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
