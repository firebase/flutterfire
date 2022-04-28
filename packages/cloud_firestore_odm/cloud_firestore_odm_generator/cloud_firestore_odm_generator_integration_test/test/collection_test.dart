import 'package:cloud_firestore_odm_generator_integration_test/simple.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'setup_firestore_mock.dart';

void main() {
  setUpAll(setupCloudFirestoreMocks);

  group('orderBy', () {
    testWidgets('applies `descending`', (tester) async {
      await Firebase.initializeApp();
      expect(
        rootRef.orderByNullable(descending: true),
        rootRef.orderByNullable(descending: true),
      );
      expect(
        rootRef.orderByNullable(descending: true),
        isNot(rootRef.orderByNullable()),
      );
      expect(
        rootRef.orderByNullable(),
        rootRef.orderByNullable(),
      );
    });
  });
}
