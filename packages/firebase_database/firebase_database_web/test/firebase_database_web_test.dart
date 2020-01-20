import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const MethodChannel channel = MethodChannel('firebase_database_web');

  TestWidgetsFlutterBinding.ensureInitialized();
}
