// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
@TestOn('browser')

import 'dart:html' as html;
import 'dart:js' as js;

import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';

import 'utils.dart';

void main() {
  group('$FirebaseCoreWeb', () {
    setUp(() async {
      js.JsObject firebaseMock = js.JsObject.jsify(<String, dynamic>{});
      js.context['firebase'] = firebaseMock;
      FirebaseCorePlatform.instance = FirebaseCoreWeb();
    });

    test('allApps() calls firebase.apps', () async {
      js.context['firebase']['apps'] = js.JsArray<FirebaseApp>();
      final List<FirebaseApp> apps = await FirebaseApp.allApps();
      expect(apps, hasLength(0));
    });

    test('appNamed() calls firebase.app', () async {
      js.context['firebase']['app'] = js.allowInterop((String name) {
        return js.JsObject.jsify(<String, dynamic>{
          'name': name,
          'options': <String, String>{'appId': '123'},
        });
      });
      final FirebaseApp app = await FirebaseApp.appNamed('foo');
      expect(app.name, equals('foo'));
    });

    test('configure() calls firebase.initializeApp', () async {
      js.context['firebase']['initializeApp'] =
          js.allowInterop((js.JsObject options, String name) {
        return js.JsObject.jsify(<String, dynamic>{
          'name': name,
          'options': options,
        });
      });
      final FirebaseApp app = await FirebaseApp.configure(
          name: 'foo', options: FirebaseOptions(googleAppID: '123'));
      expect(app.name, equals('foo'));
    });
  });
}
