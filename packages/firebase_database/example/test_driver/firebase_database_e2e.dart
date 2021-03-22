// @dart=2.9

import 'package:e2e/e2e.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_database/firebase_database.dart';

Future<void> main() async {
  E2EWidgetsFlutterBinding.ensureInitialized();

  group('$FirebaseDatabase', () {
    setUp(() async {
      await Firebase.initializeApp();
    });

    testWidgets('runTransaction', (WidgetTester tester) async {
      final FirebaseDatabase database = FirebaseDatabase.instance;
      final DatabaseReference ref = database.reference().child('counter');
      final DataSnapshot snapshot = await ref.once();
      final int value = snapshot.value ?? 0;
      final TransactionResult transactionResult =
          await ref.runTransaction((MutableData mutableData) async {
        mutableData.value = (mutableData.value ?? 0) + 1;
        return mutableData;
      });
      expect(transactionResult.committed, true);
      expect(transactionResult.dataSnapshot.value > value, true);
    });

    testWidgets('setPersistenceCacheSizeBytes Integer',
        (WidgetTester tester) async {
      final FirebaseDatabase database = FirebaseDatabase.instance;

      await database.setPersistenceCacheSizeBytes(2147483647);
    });

    testWidgets('setPersistenceCacheSizeBytes Long',
        (WidgetTester tester) async {
      final FirebaseDatabase database = FirebaseDatabase.instance;
      await database.setPersistenceCacheSizeBytes(2147483648);
    });
  });
}
