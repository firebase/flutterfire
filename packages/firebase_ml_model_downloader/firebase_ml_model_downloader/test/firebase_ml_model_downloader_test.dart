import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';

void main() {
  const MethodChannel channel = MethodChannel('firebase_ml_model_downloader');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await FirebaseMlModelDownloader.platformVersion, '42');
  });
}
