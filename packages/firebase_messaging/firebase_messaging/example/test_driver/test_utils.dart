import 'package:firebase_core/firebase_core.dart';

import 'dart:io';

// Initializes a secondary app for testing
Future<FirebaseApp> testInitializeSecondaryApp() async {
  final String testAppName = 'testapp';

  FirebaseOptions testAppOptions;
  if (Platform.isIOS || Platform.isMacOS) {
    testAppOptions = FirebaseOptions(
      appId: '1:448618578101:ios:0b650370bb29e29cac3efc',
      apiKey: 'AIzaSyAgUhHU8wSJgO5MVNy95tMT07NEjzMOfz0',
      projectId: 'react-native-firebase-testing',
      messagingSenderId: '448618578101',
      iosBundleId: 'io.flutter.plugins.firebasecoreexample',
      storageBucket: null,
    );
  } else {
    testAppOptions = FirebaseOptions(
      appId: '1:448618578101:web:0b650370bb29e29cac3efc',
      apiKey: 'AIzaSyAgUhHU8wSJgO5MVNy95tMT07NEjzMOfz0',
      projectId: 'react-native-firebase-testing',
      messagingSenderId: '448618578101',
      storageBucket: null,
    );
  }

  return Firebase.initializeApp(name: testAppName, options: testAppOptions);
}
