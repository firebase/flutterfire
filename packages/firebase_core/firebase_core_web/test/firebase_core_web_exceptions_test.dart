// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('browser')
import 'dart:js' as js;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:flutter_test/flutter_test.dart';
import 'mock/firebase_mock.dart';
import 'package:js/js_util.dart' as js_util;

void main() {
  group('no default app', () {
    setUp(() async {
      FirebasePlatform.instance = FirebaseCoreWeb();
    });

    test('should throw exception if no default app is available', () async {
      try {
        await Firebase.initializeApp();
      } on FirebaseException catch (e) {
        expect(e, coreNotInitialized());
        return;
      }

      fail("FirebaseException not thrown");
    });
  });

  group('.initializeApp()', () {
    setUp(() async {
      FirebasePlatform.instance = FirebaseCoreWeb();
    });

    test('should throw exception if trying to initialize default app',
        () async {
      try {
        await Firebase.initializeApp(name: defaultFirebaseAppName);
      } on FirebaseException catch (e) {
        expect(e, noDefaultAppInitialization());
        return;
      }

      fail("FirebaseException not thrown");
    });

    group('secondary apps', () {
      test('should throw exception if no options are provided with a named app',
          () async {
        try {
          await Firebase.initializeApp(name: 'foo');
        } catch (e) {
          assert(
              e.toString().contains(
                  "FirebaseOptions cannot be null when creating a secondary Firebase app."),
              true);
        }
      });
    });
  });

  group('.app()', () {
    setUp(() async {
      firebaseMock = FirebaseMock(app: js.allowInterop((String name) {
        final dynamic error = js_util.newObject();
        js_util.setProperty(error, 'name', 'FirebaseError');
        js_util.setProperty(error, 'code', 'app/no-app');
        throw error;
      }));
      FirebasePlatform.instance = FirebaseCoreWeb();
    });

    test('should throw exception if no named app was found', () async {
      String name = 'foo';

      try {
        Firebase.app(name);
      } on FirebaseException catch (e) {
        expect(e, noAppExists(name));
        return;
      }

      fail("FirebaseException not thrown");
    });
  });
}
