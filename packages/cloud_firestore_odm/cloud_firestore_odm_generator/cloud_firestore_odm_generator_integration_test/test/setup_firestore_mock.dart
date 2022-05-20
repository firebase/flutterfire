// ignore_for_file: avoid_dynamic_calls

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> setupCloudFirestoreMocks() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelFirebase.channel.setMockMethodCallHandler((call) async {
    if (call.method == 'Firebase#initializeCore') {
      return [
        {
          'name': defaultFirebaseAppName,
          'options': {
            'apiKey': '123',
            'appId': '123',
            'messagingSenderId': '123',
            'projectId': '123',
          },
          'pluginConstants': <String, Object?>{},
        }
      ];
    }

    if (call.method == 'Firebase#initializeApp') {
      return <String, Object?>{
        'name': call.arguments['appName'],
        'options': call.arguments['options'],
        'pluginConstants': <String, Object?>{},
      };
    }

    return null;
  });

  await Firebase.initializeApp();
}
