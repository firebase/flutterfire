// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('browser')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:firebase_core_web/src/interop/core.dart' as firebase;
import 'package:firebase_core_web/src/interop_token_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('with stand-in components', () {
    late Map<String, JSObject> loaded;
    late List<String> calls;
    late bool notificationsGranted;
    late InteropTokenProvider provider;

    setUp(() {
      loaded = {};
      calls = [];
      notificationsGranted = false;
      provider = InteropTokenProvider(
        getComponent: (name) => loaded[name],
        notificationsGranted: () => notificationsGranted,
      );
    });

    JSObject component(Map<String, JSPromise<JSAny?> Function()> methods) {
      final object = JSObject();
      methods.forEach((name, method) {
        object[name] = (() {
          calls.add(name);
          return method();
        }).toJS;
      });
      return object;
    }

    group('getAuthIdToken', () {
      test('is null when Auth is not loaded', () async {
        expect(await provider.getAuthIdToken(), isNull);
      });

      test('is null when nobody is signed in', () async {
        loaded['auth-internal'] = component({'getToken': () => _resolve(null)});

        expect(await provider.getAuthIdToken(), isNull);
      });

      test("is the signed-in user's access token", () async {
        loaded['auth-internal'] = component({
          'getToken': () =>
              _resolve(JSObject()..['accessToken'] = 'id-token'.toJS),
        });

        expect(await provider.getAuthIdToken(), 'id-token');
      });

      test("throws a core FirebaseException with Auth's message", () async {
        loaded['auth-internal'] = component({
          'getToken': () => _reject('A network error has occurred.'),
        });

        await expectLater(
          provider.getAuthIdToken(),
          throwsA(
            isA<FirebaseException>()
                .having((e) => e.plugin, 'plugin', 'core')
                .having((e) => e.code, 'code', 'auth-token-failed')
                .having(
                  (e) => e.message,
                  'message',
                  'A network error has occurred.',
                ),
          ),
        );
      });
    });

    group('getAppCheckToken', () {
      test('is null when App Check is not loaded or activated', () async {
        expect(await provider.getAppCheckToken(limitedUse: false), isNull);
      });

      test('carries the token', () async {
        loaded['app-check-internal'] = component({
          'getToken': () =>
              _resolve(JSObject()..['token'] = 'app-check-token'.toJS),
        });

        expect(
          await provider.getAppCheckToken(limitedUse: false),
          const AppCheckInteropToken(token: 'app-check-token'),
        );
        expect(calls, ['getToken']);
      });

      test('carries the placeholder and the error together', () async {
        loaded['app-check-internal'] = component({
          'getToken': () => _resolve(
            JSObject()
              ..['token'] = 'placeholder'.toJS
              ..['error'] = _jsError('AppCheck: Fetch server returned 403.'),
          ),
        });

        expect(
          await provider.getAppCheckToken(limitedUse: false),
          const AppCheckInteropToken(
            token: 'placeholder',
            error: 'AppCheck: Fetch server returned 403.',
          ),
        );
      });

      test('asks for a limited-use token on request', () async {
        loaded['app-check-internal'] = component({
          'getToken': () => _resolve(JSObject()..['token'] = 'regular'.toJS),
          'getLimitedUseToken': () =>
              _resolve(JSObject()..['token'] = 'limited-use'.toJS),
        });

        final answer = await provider.getAppCheckToken(limitedUse: true);

        expect(answer?.token, 'limited-use');
        expect(calls, ['getLimitedUseToken']);
      });
    });

    group('getMessagingToken', () {
      test(
        'is null, without asking Messaging, until notifications are allowed',
        () async {
          loaded['messaging-internal'] = component({
            'getToken': () => _resolve('fcm-token'.toJS),
          });

          expect(await provider.getMessagingToken(), isNull);
          expect(calls, isEmpty);
        },
      );

      test('is null when Messaging is not loaded', () async {
        notificationsGranted = true;

        expect(await provider.getMessagingToken(), isNull);
      });

      test('is the token once notifications are allowed', () async {
        notificationsGranted = true;
        loaded['messaging-internal'] = component({
          'getToken': () => _resolve('fcm-token'.toJS),
        });

        expect(await provider.getMessagingToken(), 'fcm-token');
      });

      test(
        'is null when Messaging fails, as in the JS Functions SDK',
        () async {
          notificationsGranted = true;
          loaded['messaging-internal'] = component({
            'getToken': () => _reject('Messaging: permission-blocked'),
          });

          expect(await provider.getMessagingToken(), isNull);
        },
      );
    });
  });

  // Loads the real Firebase JS SDK files, as firebase_core_web does, so these
  // tests check the lookups against the components the SDK registers.
  group('with the Firebase JS SDK', () {
    late FirebaseCoreWeb coreWeb;
    late FirebaseAppPlatform app;

    JSObject module(String windowVariable) =>
        globalContext[windowVariable]! as JSObject;

    JSObject jsApp() =>
        module('firebase_core').callMethod<JSObject>('getApp'.toJS);

    Future<void> load(String product) => coreWeb.injectSrcScript(
      'https://www.gstatic.com/firebasejs/'
          '${coreWeb.firebaseSDKVersion}/firebase-$product.js',
      'firebase_${product.replaceAll('-', '_')}',
    );

    setUpAll(() async {
      FirebasePlatform.instance = coreWeb = FirebaseCoreWeb();
      await load('app');
      await FirebasePlatform.instance.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'fake-api-key',
          appId: '1:1234567890:web:fake',
          messagingSenderId: '1234567890',
          projectId: 'fake-project',
        ),
      );
      app = FirebasePlatform.instance.app();
    });

    test('every token is null when only firebase-app.js is loaded', () async {
      expect(await app.getAuthIdToken(), isNull);
      expect(await app.getAppCheckToken(), isNull);
      expect(await app.getMessagingToken(), isNull);
    });

    test(
      "a signed-out user's token is null once Auth is initialized",
      () async {
        await load('auth');
        module('firebase_auth').callMethod<JSObject>('getAuth'.toJS, jsApp());

        final authInternal = firebase
            .getProvider(firebase.app().jsObject, 'auth-internal'.toJS)
            .getImmediate(firebase.ProviderGetImmediateOptions(optional: true));
        expect(
          authInternal,
          isNotNull,
          reason: 'Auth registered its component',
        );
        expect(await app.getAuthIdToken(), isNull);
      },
    );

    test("the token is App Check's once App Check is activated", () async {
      await load('app-check');
      expect(
        await app.getAppCheckToken(),
        isNull,
        reason: 'App Check is loaded but not activated yet',
      );

      final appCheck = module('firebase_app_check');
      final customProvider = (appCheck['CustomProvider']! as JSFunction)
          .callAsConstructor<JSObject>(
            JSObject()
              ..['getToken'] = (() => _resolve(
                JSObject()
                  ..['token'] = 'custom-app-check-token'.toJS
                  ..['expireTimeMillis'] = DateTime.now()
                      .add(const Duration(hours: 1))
                      .millisecondsSinceEpoch
                      .toJS,
              )).toJS,
          );
      appCheck.callMethod<JSObject>(
        'initializeAppCheck'.toJS,
        jsApp(),
        JSObject()
          ..['provider'] = customProvider
          ..['isTokenAutoRefreshEnabled'] = false.toJS,
      );

      expect(
        await app.getAppCheckToken(),
        const AppCheckInteropToken(token: 'custom-app-check-token'),
      );
      expect(
        (await app.getAppCheckToken(limitedUse: true))?.token,
        'custom-app-check-token',
      );
    });

    test(
      'the Messaging token is null while notifications are not allowed',
      () async {
        await load('messaging');

        expect(await app.getMessagingToken(), isNull);
      },
    );

    test('a deleted app fails with no-app', () async {
      await FirebasePlatform.instance.initializeApp(
        name: 'deleted',
        options: app.options,
      );
      final deleted = FirebasePlatform.instance.app('deleted');
      await deleted.delete();

      await expectLater(
        deleted.getAuthIdToken(),
        throwsA(
          isA<FirebaseException>().having((e) => e.code, 'code', 'no-app'),
        ),
      );
    });
  });
}

JSPromise<JSAny?> _resolve(JSAny? value) => Future<JSAny?>.value(value).toJS;

JSPromise<JSAny?> _reject(String message) =>
    (globalContext['Promise']! as JSObject).callMethod<JSPromise<JSAny?>>(
      'reject'.toJS,
      _jsError(message),
    );

JSObject _jsError(String message) => (globalContext['Error']! as JSFunction)
    .callAsConstructor<JSObject>(message.toJS);
