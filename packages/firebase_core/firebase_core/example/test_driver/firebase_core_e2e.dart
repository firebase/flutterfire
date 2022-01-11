// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:drive/drive.dart' as drive;

import 'firebase_config.dart';

void main() => drive.main(testsMain);

void testsMain() {
  String testAppName = 'TestApp';
  FirebaseOptions? testAppOptions = TestFirebaseConfig.platformOptions;

  setUpAll(() async {
    await Firebase.initializeApp(name: testAppName, options: testAppOptions);
  });

  test('Firebase.apps', () async {
    List<FirebaseApp> apps = Firebase.apps;
    expect(apps.length, 1);
    expect(apps[0].name, testAppName);
    expect(apps[0].options, testAppOptions);
  });

  test('Firebase.app()', () async {
    FirebaseApp app = Firebase.app(testAppName);

    expect(app.name, testAppName);
    expect(app.options, testAppOptions);
  });

  test('Firebase.app() Exception', () async {
    expect(
      () => Firebase.app('NoApp'),
      throwsA(noAppExists('NoApp')),
    );
  });

  test('FirebaseApp.delete()', () async {
    await Firebase.initializeApp(name: 'SecondaryApp', options: testAppOptions);

    expect(Firebase.apps.length, 2);

    FirebaseApp app = Firebase.app('SecondaryApp');

    await app.delete();

    expect(Firebase.apps.length, 1);
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
