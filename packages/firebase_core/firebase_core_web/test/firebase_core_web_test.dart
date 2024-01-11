// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('browser')
import 'dart:js' as js;

import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mock/firebase_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$FirebaseCoreWeb', () {
    setUp(() async {
      firebaseMock = FirebaseMock(
        app: js.allowInterop(
          (String name) => FirebaseAppMock(
            name: name,
            options: FirebaseAppOptionsMock(
              apiKey: 'abc',
              appId: '123',
              messagingSenderId: 'msg',
              projectId: 'test',
            ),
          ),
        ),
      );

      FirebasePlatform.instance = FirebaseCoreWeb();
    });

    test('.apps', () {
      (js.context['firebase_core'] as js.JsObject)['getApps'] =
          js.allowInterop(js.JsArray<dynamic>.new);
      final List<FirebaseAppPlatform> apps = FirebasePlatform.instance.apps;
      expect(apps, hasLength(0));
    });
  });
}
