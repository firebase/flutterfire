// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
@TestOn('browser')

import 'dart:js' as js;

import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';

void main() {
  group('$FirebaseCoreWeb', () {
    FirebaseCoreWeb firebaseCoreWeb;
    setUp(() async {
      final js.JsObject firebaseMock = js.JsObject.jsify(<String, dynamic>{});
      js.context['firebase'] = firebaseMock;
      firebaseCoreWeb = FirebaseCoreWeb();
    });

    test('allApps() calls firebase.apps', () async {
      js.context['firebase']['apps'] = js.JsArray<dynamic>();
      final List<PlatformFirebaseApp> apps = await firebaseCoreWeb.allApps();
      expect(apps, hasLength(0));
    });

    test('appNamed() calls firebase.app', () async {
      js.context['firebase']['app'] = js.allowInterop((String name) {
        return js.JsObject.jsify(<String, dynamic>{
          'name': name,
          'options': <String, String>{'appId': '123'},
        });
      });
      final PlatformFirebaseApp app = await firebaseCoreWeb.appNamed('foo');
      expect(app.name, equals('foo'));
      expect(app.options.googleAppID, equals('123'));
    });

    test('configure() calls firebase.initializeApp', () async {
      String appName;
      js.JsObject appOptions;

      js.context['firebase']['initializeApp'] =
          js.allowInterop((js.JsObject options, String name) {
        appName = name;
        appOptions = options;
        return js.JsObject.jsify(<String, dynamic>{
          'name': name,
          'options': options,
        });
      });
      firebaseCoreWeb.configure(
          'foo', const FirebaseOptions(googleAppID: '123'));
      expect(appName, equals('foo'));
      expect(appOptions['appId'], equals('123'));
    });
  });
}
