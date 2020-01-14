// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
@TestOn('chrome')

import 'dart:async';
import 'dart:js' show allowInterop;

import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_auth_web/firebase_auth_web.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_core_web/firebase_core_web.dart';

import 'mock/firebase_mock.dart';

void main() {
  group('$FirebaseAuthWeb', () {
    setUp(() {
      firebaseMock = FirebaseMock(
          app: allowInterop(
        (String name) => FirebaseAppMock(
          name: name,
          options: FirebaseAppOptionsMock(appId: '123'),
        ),
      ));

      FirebaseCorePlatform.instance = FirebaseCoreWeb();
      FirebaseAuthPlatform.instance = FirebaseAuthWeb();
    });

    test('signInAnonymously calls Firebase APIs', () async {
      firebaseMock.auth = allowInterop((_) => FirebaseAuthMock(
            signInAnonymously: allowInterop(() {
              return _jsPromise(_fakeUserCredential());
            }),
          ));

      FirebaseAuth auth = FirebaseAuth.instance;
      AuthResult result = await auth.signInAnonymously();
      expect(result, isNotNull);
    });

    group('onAuthStateChanged', () {
      final List seenUsers = [];
      final Completer<Function> nextUserCallback = Completer<Function>();

      final List<dynamic> streamValues = [_fakeRawUser(), null, _fakeRawUser()];
      final List<dynamic> expectedValueMatchers = [
        isNotNull,
        isNull,
        isA<FirebaseUser>()
      ];

      test('non authenticated user present in stream', () async {
        firebaseMock.auth = allowInterop((_) => FirebaseAuthMock(
              onAuthStateChanged:
                  allowInterop((Function nextUserCb, Function errorCb) {
                if (!nextUserCallback.isCompleted) {
                  nextUserCallback.complete(nextUserCb);
                }
                return allowInterop(() {});
              }),
            ));

        FirebaseAuth auth = FirebaseAuth.instance;

        // Subscribe our spy function
        auth.onAuthStateChanged
            .listen((FirebaseUser user) => seenUsers.add(user));

        // Capture the JS function that lets us push users to the Stream from JS.
        Function nextUser = await nextUserCallback.future;

        streamValues.forEach((streamValue) => nextUser(streamValue));

        for (int i = 0; i < expectedValueMatchers.length; i++) {
          expect(seenUsers[i], expectedValueMatchers[i]);
        }
      });
    });
  });
}

Promise _jsPromise(dynamic value) {
  return Promise(allowInterop((void resolve(dynamic result), Function reject) {
    resolve(value);
  }));
}

MockUserCredential _fakeUserCredential() {
  return MockUserCredential(
    user: _fakeRawUser(),
    additionalUserInfo: MockAdditionalUserInfo(),
  );
}

MockUser _fakeRawUser() {
  return MockUser(
    providerId: 'email',
    metadata: MockUserMetadata(
      creationTime: 'Wed, 04 Dec 2019 18:19:11 GMT',
      lastSignInTime: 'Wed, 04 Dec 2019 18:19:11 GMT',
    ),
    providerData: [],
  );
}
