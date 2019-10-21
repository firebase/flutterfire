import 'package:flutter_test/flutter_test.dart';
import 'package:e2e/e2e.dart';

import 'package:firebase_storage/firebase_storage.dart';

void main() {
  E2EWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Can get bucket', (WidgetTester tester) async {
    final Future<String> future = FirebaseStorage().ref().getBucket();
    expect(future, completes);
  });
}
