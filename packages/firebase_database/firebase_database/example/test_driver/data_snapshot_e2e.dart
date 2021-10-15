import 'package:flutter_test/flutter_test.dart';

import 'firebase_database_e2e.dart';

void runDataSnapshotTests() {
  group('DataSnapshot', () {
    test('supports null childKeys for maps', () async {
      // Regression test for https://github.com/FirebaseExtended/flutterfire/issues/6002

      final ref = database.ref('flutterfire');

      final transactionResult = await ref.runTransaction((mutableData) {
        mutableData.value = {'v': 'vala'};
        return mutableData;
      });

      expect(transactionResult.committed, true);
      expect(transactionResult.dataSnapshot!.value, {'v': 'vala'});
    });
  });
}
