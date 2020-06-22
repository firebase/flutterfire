import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_ml/firebase_ml.dart';

void main() {
  const MethodChannel channel = MethodChannel('plugins.flutter.io/firebase_ml');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('doSomething', () async {
    expect(await FirebaseML.doSomething, '42');
  });
}
