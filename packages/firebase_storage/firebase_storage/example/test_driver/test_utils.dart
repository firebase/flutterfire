// @dart = 2.9

import 'dart:io';
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

final String kTestString = ([]..length = pow(2, 12)).join(_getRandomString(8));
const String kTestStorageBucket = 'react-native-firebase-testing.appspot.com';

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _random = Random();
String _getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_random.nextInt(_chars.length))));

// Creates a test file with a specified name to
// a locally directory
Future<File> createFile(String name) async {
  final Directory systemTempDir = Directory.systemTemp;
  final File file = await File('${systemTempDir.path}/$name').create();
  await file.writeAsString(kTestString);
  return file;
}

// Initializes a secondary app with or without a
// default storageBucket value in FirebaseOptions for testing
Future<FirebaseApp> testInitializeSecondaryApp(
    {bool withDefaultBucket = true}) async {
  final String testAppName =
      withDefaultBucket ? 'testapp' : 'testapp-no-bucket';

  FirebaseOptions testAppOptions;
  if (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) {
    testAppOptions = FirebaseOptions(
      appId: '1:448618578101:ios:0b650370bb29e29cac3efc',
      apiKey: 'AIzaSyAgUhHU8wSJgO5MVNy95tMT07NEjzMOfz0',
      projectId: 'react-native-firebase-testing',
      messagingSenderId: '448618578101',
      iosBundleId: 'io.flutter.plugins.firebasecoreexample',
      storageBucket: withDefaultBucket ? kTestStorageBucket : null,
    );
  } else {
    testAppOptions = FirebaseOptions(
      appId: '1:448618578101:web:0b650370bb29e29cac3efc',
      apiKey: 'AIzaSyAgUhHU8wSJgO5MVNy95tMT07NEjzMOfz0',
      projectId: 'react-native-firebase-testing',
      messagingSenderId: '448618578101',
      storageBucket: withDefaultBucket ? kTestStorageBucket : null,
    );
  }

  return Firebase.initializeApp(name: testAppName, options: testAppOptions);
}
