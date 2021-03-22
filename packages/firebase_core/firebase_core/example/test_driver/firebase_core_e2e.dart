// @dart = 2.9

// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// @dart=2.9

import 'dart:io';
import 'package:e2e/e2e.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  E2EWidgetsFlutterBinding.ensureInitialized();

  String testAppName = 'TestApp';
  FirebaseOptions testAppOptions;
  if (Platform.isIOS || Platform.isMacOS) {
    testAppOptions = const FirebaseOptions(
      appId: '1:448618578101:ios:0b650370bb29e29cac3efc',
      apiKey: 'AIzaSyAgUhHU8wSJgO5MVNy95tMT07NEjzMOfz0',
      projectId: 'react-native-firebase-testing',
      messagingSenderId: '448618578101',
      iosBundleId: 'io.flutter.plugins.firebasecoreexample',
    );
  } else {
    testAppOptions = const FirebaseOptions(
      appId: '1:448618578101:web:0b650370bb29e29cac3efc',
      apiKey: 'AIzaSyAgUhHU8wSJgO5MVNy95tMT07NEjzMOfz0',
      projectId: 'react-native-firebase-testing',
      messagingSenderId: '448618578101',
    );
  }

  setUpAll(() async {
    await Firebase.initializeApp(name: testAppName, options: testAppOptions);
  });

  testWidgets('Firebase.apps', (WidgetTester tester) async {
    List<FirebaseApp> apps = Firebase.apps;

    expect(apps.length, 2);
    expect(apps[1].name, testAppName);
    expect(apps[1].options, testAppOptions);
  });

  testWidgets('Firebase.app()', (WidgetTester tester) async {
    FirebaseApp app = Firebase.app(testAppName);

    expect(app.name, testAppName);
    expect(app.options, testAppOptions);
  });

  testWidgets('Firebase.app() Exception', (WidgetTester tester) async {
    expect(
      () => Firebase.app('NoApp'),
      throwsA(noAppExists('NoApp')),
    );
  });

  testWidgets('FirebaseApp.delete()', (WidgetTester tester) async {
    await Firebase.initializeApp(name: 'SecondaryApp', options: testAppOptions);

    expect(Firebase.apps.length, 3);

    FirebaseApp app = Firebase.app('SecondaryApp');

    await app.delete();

    expect(Firebase.apps.length, 2);
  });

  testWidgets('FirebaseApp.setAutomaticDataCollectionEnabled()',
      (WidgetTester tester) async {
    FirebaseApp app = Firebase.app(testAppName);
    bool enabled = app.isAutomaticDataCollectionEnabled;

    await app.setAutomaticDataCollectionEnabled(!enabled);

    expect(app.isAutomaticDataCollectionEnabled, !enabled);
  });

  testWidgets('FirebaseApp.setAutomaticResourceManagementEnabled()',
      (WidgetTester tester) async {
    FirebaseApp app = Firebase.app(testAppName);

    await app.setAutomaticResourceManagementEnabled(true);
  });
}
