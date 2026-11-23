// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('chrome')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:firebase_app_check_platform_interface/firebase_app_check_platform_interface.dart';
import 'package:firebase_app_check_web/firebase_app_check_web.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter_test/flutter_test.dart';

/// Stands in for the parts of the Firebase JS SDK that `activate` and
/// `getToken` reach, recording every `initializeAppCheck` call.
const _fakeJsSdk = '''
globalThis.__initializeAppCheckCalls = [];
globalThis.firebase_core = { getApp: (name) => ({ name }) };
globalThis.firebase_app_check = {
  initializeAppCheck: (app, options) => {
    globalThis.__initializeAppCheckCalls.push(app.name);
    return { app };
  },
  getToken: (appCheck) =>
    Promise.resolve({ token: 'token for ' + appCheck.app.name }),
  onTokenChanged: () => () => {},
  ReCaptchaV3Provider: function (siteKey) { this.siteKey = siteKey; },
  ReCaptchaEnterpriseProvider: function (siteKey) { this.siteKey = siteKey; },
};
''';

List<String> get _initializeAppCheckCalls => globalContext
    .getProperty<JSArray<JSString>>('__initializeAppCheckCalls'.toJS)
    .toDart
    .map((name) => name.toDart)
    .toList();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();

  var appCount = 0;

  setUpAll(() => globalContext.callMethod('eval'.toJS, _fakeJsSdk.toJS));

  tearDownAll(() {
    for (final name in [
      'firebase_core',
      'firebase_app_check',
      '__initializeAppCheckCalls',
    ]) {
      globalContext.delete(name.toJS);
    }
  });

  setUp(
    () => globalContext.setProperty(
      '__initializeAppCheckCalls'.toJS,
      JSArray<JSString>(),
    ),
  );

  Future<FirebaseApp> newApp() => Firebase.initializeApp(
    name: 'activate-${appCount++}',
    options: const FirebaseOptions(
      apiKey: '',
      appId: '',
      messagingSenderId: '',
      projectId: '',
    ),
  );

  group('$FirebaseAppCheckWeb.activate', () {
    test('initializes the JS App Check of an app once, however many times '
        'and from however many delegates it is activated', () async {
      final app = await newApp();
      // What FirebaseAppCheck, registerWith and the app's AppCheckTokenProvider
      // each hold.
      final first = FirebaseAppCheckWeb(app: app);
      final second = FirebaseAppCheckWeb(app: app);

      await first.activate(providerWeb: ReCaptchaV3Provider('site-key'));
      await first.activate(providerWeb: ReCaptchaV3Provider('site-key'));
      await second.activate(providerWeb: ReCaptchaV3Provider('site-key'));

      expect(_initializeAppCheckCalls, [app.name]);
      expect(await second.getToken(false), 'token for ${app.name}');
    });

    test('lets a delegate created after activation use the instance', () async {
      final app = await newApp();
      await FirebaseAppCheckWeb(
        app: app,
      ).activate(providerWeb: ReCaptchaV3Provider('site-key'));

      expect(
        await FirebaseAppCheckWeb(app: app).getToken(false),
        'token for ${app.name}',
      );
      expect(_initializeAppCheckCalls, [app.name]);
    });

    test('keeps the instances of different apps apart', () async {
      final app = await newApp();
      final other = await newApp();

      await FirebaseAppCheckWeb(
        app: app,
      ).activate(providerWeb: ReCaptchaV3Provider('site-key'));
      await FirebaseAppCheckWeb(
        app: other,
      ).activate(providerWeb: ReCaptchaV3Provider('site-key'));

      expect(_initializeAppCheckCalls, [app.name, other.name]);
      expect(
        await FirebaseAppCheckWeb(app: other).getToken(false),
        'token for ${other.name}',
      );
    });
  });
}
