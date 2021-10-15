import 'package:flutter_test/flutter_test.dart';

import 'firebase_database_e2e.dart';

void runDatabaseTests() {
  group('FirebaseDatabase.ref()', () {
    test('returns a correct reference', () async {
      final snapshot = await database.ref('flutterfire').get();
      expect(snapshot.key, 'flutterfire');
      expect(snapshot.value, 0);
    });

    test(
      'returns a reference to the root of the database if no path specified',
      () async {
        final ref = database.ref().child('flutterfire');
        final snapshot = await ref.get();
        expect(snapshot.key, 'flutterfire');
        expect(snapshot.value, 0);
      },
    );
  });
}
