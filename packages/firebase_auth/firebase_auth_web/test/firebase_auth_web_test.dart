// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
@TestOn('chrome')

import 'dart:js' as js;

import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_auth_web/firebase_auth_web.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_core_web/firebase_core_web.dart';

void main() {
  group('$FirebaseAuthWeb', () {
    setUp(() {
      final js.JsObject firebaseMock = js.JsObject.jsify(<String, dynamic>{});
      js.context['firebase'] = firebaseMock;
      js.context['firebase']['app'] = js.allowInterop((String name) {
        return js.JsObject.jsify(<String, dynamic>{
          'name': name,
          'options': <String, String>{'appId': '123'},
        });
      });
      js.context['firebase']['auth'] = js.allowInterop((dynamic app) {});
      FirebaseCorePlatform.instance = FirebaseCoreWeb();
      FirebaseAuthPlatform.instance = FirebaseAuthWeb();
    });

    test('signInAnonymously calls Firebase APIs', () async {
      js.context['firebase']['auth'] = js.allowInterop((dynamic app) {
        return js.JsObject.jsify(
          <String, dynamic>{
            'signInAnonymously': () {
              return _jsPromise(_fakeUserCredential());
            },
          },
        );
      });
      FirebaseAuth auth = FirebaseAuth.instance;
      AuthResult result = await auth.signInAnonymously();
      expect(result, isNotNull);
    });
  });
}

js.JsObject _jsPromise(dynamic value) {
  return js.JsObject.jsify(<String, dynamic>{
    'then': (js.JsFunction f) {
      f.apply(<dynamic>[value]);
    },
  });
}

js.JsObject _fakeUserCredential() {
  return js.JsObject.jsify(<String, dynamic>{
    'user': <String, dynamic>{
      'providerId': 'email',
      'metadata': <String, dynamic>{
        'creationTime': '2019-12-01T00:53:11Z',
        'lastSignInTime': '2019-12-01T00:53:11Z',
      },
      'providerData': <dynamic>[],
    },
    'additionalUserInfo': <String, dynamic>{},
  });
}
