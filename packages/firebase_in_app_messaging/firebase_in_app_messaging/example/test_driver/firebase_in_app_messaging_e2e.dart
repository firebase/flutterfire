// @dart = 2.9

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drive/drive.dart' as drive;

void main() => drive.main(testsMain);

void testsMain() {
  group('$FirebaseInAppMessaging', () {
    setUpAll(() async {
      await Firebase.initializeApp();
    });

    test('triggerEvent', () async {
      expect(
        FirebaseInAppMessaging.instance.triggerEvent('someEvent'),
        completes,
      );
    });

    test('logging', () async {
      expect(
        FirebaseInAppMessaging.instance.setMessagesSuppressed(true),
        completes,
      );
      expect(
        FirebaseInAppMessaging.instance.setAutomaticDataCollectionEnabled(true),
        completes,
      );
    });
  });
}
