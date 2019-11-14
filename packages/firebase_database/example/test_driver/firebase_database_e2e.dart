import 'package:e2e/e2e.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_database/firebase_database.dart';

void main() {
  E2EWidgetsFlutterBinding.ensureInitialized();

  group('$FirebaseDatabase', () {
    final FirebaseDatabase database = FirebaseDatabase.instance;

    testWidgets('runTransaction', (WidgetTester tester) async {
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
  });
}
