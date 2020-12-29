// @dart = 2.9

// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
// ignore: import_of_legacy_library_into_null_safe
import 'package:drive/drive.dart' as drive;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void testsMain() {
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

  test('Firebase.apps', () async {
    List<FirebaseApp> apps = Firebase.apps;
    expect(apps.length, 2);
    expect(apps[1].name, testAppName);
    expect(apps[1].options, testAppOptions);
  });

  test('Firebase.app()', () async {
    FirebaseApp app = Firebase.app(testAppName);
    expect(app.name, testAppName);
    expect(app.options, testAppOptions);
  });

  test('Firebase.app() Exception', () async {
    try {
      await Firebase.app('NoApp');
    } on FirebaseException catch (e) {
      expect(e, noAppExists('NoApp'));
      return;
    }
  });

  test('FirebaseApp.delete()', () async {
    await Firebase.initializeApp(name: 'SecondaryApp', options: testAppOptions);
    expect(Firebase.apps.length, 3);
    FirebaseApp app = Firebase.app('SecondaryApp');
    await app.delete();
    expect(Firebase.apps.length, 2);
  });

  test('FirebaseApp.setAutomaticDataCollectionEnabled()', () async {
    FirebaseApp app = Firebase.app(testAppName);
    bool enabled = app.isAutomaticDataCollectionEnabled;
    await app.setAutomaticDataCollectionEnabled(!enabled);
    expect(app.isAutomaticDataCollectionEnabled, !enabled);
  });

  test('FirebaseApp.setAutomaticResourceManagementEnabled()', () async {
    FirebaseApp app = Firebase.app(testAppName);
    await app.setAutomaticResourceManagementEnabled(true);
  });
}

void main() => drive.main(testsMain);
