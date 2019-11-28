import 'package:flutter_test/flutter_test.dart';
import 'package:e2e/e2e.dart';

// ignore: avoid_relative_lib_imports
import '../lib/firebase_storage.dart';

void main() {
  E2EWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Can get bucket', (WidgetTester tester) async {
    final Future<String> future = FirebaseStorage().ref().getBucket();
    expect(future, completes);
  });

  testWidgets('Can get metadata', (WidgetTester tester) async {
    final Future<StorageMetadata> future =
        FirebaseStorage().ref().getMetadata();
    expect(future, completes);
  });
}
