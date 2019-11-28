// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
@TestOn('browser')

import 'dart:js' as js;

import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';

void main() {
  group('$FirebaseCoreWeb', () {
    setUp(() async {
      final js.JsObject firebaseMock = js.JsObject.jsify(<String, dynamic>{});
      js.context['firebase'] = firebaseMock;
      FirebaseCorePlatform.instance = FirebaseCoreWeb();
    });

    test('FirebaseApp.allApps() calls firebase.apps', () async {
      js.context['firebase']['apps'] = js.JsArray<dynamic>();
      final List<FirebaseApp> apps = await FirebaseApp.allApps();
      expect(apps, hasLength(0));
    });

    test('FirebaseApp.appNamed() calls firebase.app', () async {
      js.context['firebase']['app'] = js.allowInterop((String name) {
        return js.JsObject.jsify(<String, dynamic>{
          'name': name,
          'options': <String, String>{'appId': '123'},
        });
      });
      final FirebaseApp app = await FirebaseApp.appNamed('foo');
      expect(app.name, equals('foo'));

      final FirebaseOptions options = await app.options;
      expect(options.googleAppID, equals('123'));
    });

    test('FirebaseApp.configure() calls firebase.initializeApp', () async {
      bool appConfigured = false;

      js.context['firebase']['app'] = js.allowInterop((String name) {
        if (appConfigured) {
          return js.JsObject.jsify(<String, dynamic>{
            'name': name,
            'options': <String, String>{'appId': '123'},
          });
        } else {
          return null;
        }
      });
      js.context['firebase']['initializeApp'] =
          js.allowInterop((js.JsObject options, String name) {
        appConfigured = true;
        return js.JsObject.jsify(<String, dynamic>{
          'name': name,
          'options': options,
        });
      });
      final FirebaseApp app = await FirebaseApp.configure(
        name: 'foo',
        options: const FirebaseOptions(googleAppID: '123'),
      );
      expect(app.name, equals('foo'));

      final FirebaseOptions options = await app.options;
      expect(options.googleAppID, equals('123'));
    });
  });
}
