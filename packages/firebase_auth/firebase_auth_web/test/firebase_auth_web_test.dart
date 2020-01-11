// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
@TestOn('chrome')

import 'dart:async';
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
            'signInAnonymously': js.allowInterop(() {
              return _jsPromise(_fakeUserCredential());
            }),
          },
        );
      });
      FirebaseAuth auth = FirebaseAuth.instance;
      AuthResult result = await auth.signInAnonymously();
      expect(result, isNotNull);
    });

    group('onAuthStateChanged', () {
      final List seenUsers = [];
      final Completer<js.JsFunction> nextUserCallback =
          Completer<js.JsFunction>();

      final List<dynamic> streamValues = [_fakeRawUser(), null, _fakeRawUser()];
      final List<dynamic> expectedValueMatchers = [
        isA<FirebaseUser>(),
        isNull,
        isA<FirebaseUser>()
      ];

      test('non authenticated user present in stream', () async {
        js.context['firebase']['auth'] = js.allowInterop((dynamic app) {
          return js.JsObject.jsify(
            <String, dynamic>{
              'onAuthStateChanged': js.allowInterop(
                  (js.JsFunction nextUserCb, js.JsFunction errorCb) {
                if (!nextUserCallback.isCompleted) {
                  nextUserCallback.complete(nextUserCb);
                }
                return js.allowInterop(() {});
              }),
            },
          );
        });

        FirebaseAuth auth = FirebaseAuth.instance;

        // Subscribe our spy function
        auth.onAuthStateChanged
            .listen((FirebaseUser user) => seenUsers.add(user));

        // Capture the JS function that lets us push users to the Stream from JS.
        js.JsFunction nextUser = await nextUserCallback.future;

        streamValues.forEach((streamValue) => nextUser.apply([streamValue]));

        for (int i = 0; i < expectedValueMatchers.length; i++) {
          expect(seenUsers[i], expectedValueMatchers[i]);
        }
      });
    });
  });
}

js.JsObject _jsPromise(dynamic value) {
  return js.JsObject.jsify(<String, dynamic>{
    'then': js.allowInterop((js.JsFunction resolve, js.JsFunction reject) {
      resolve.apply(<dynamic>[value]);
    }),
  });
}

js.JsObject _fakeUserCredential() {
  return js.JsObject.jsify(<String, dynamic>{
    'user': <String, dynamic>{
      'providerId': 'email',
      'metadata': <String, dynamic>{
        'creationTime': 'Wed, 04 Dec 2019 18:19:11 GMT',
        'lastSignInTime': 'Wed, 04 Dec 2019 18:19:11 GMT',
      },
      'providerData': <dynamic>[],
    },
    'additionalUserInfo': <String, dynamic>{},
  });
}

js.JsObject _fakeRawUser() {
  return js.JsObject.jsify(<String, dynamic>{
    'providerId': 'email',
    'metadata': <String, dynamic>{
      'creationTime': 'Wed, 04 Dec 2019 18:19:11 GMT',
      'lastSignInTime': 'Wed, 04 Dec 2019 18:19:11 GMT',
    },
    'providerData': <dynamic>[],
  });
}
