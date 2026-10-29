// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('browser')
library;

import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('App Check multi-app initialization', () {
    setUp(() async {
      FirebasePlatform.instance = FirebaseCoreWeb();
    });

    test(
      'keeps app-check registered and re-runs ensurePluginInitialized for named apps',
      () async {
        final initializedAppNames = <String>[];

        FirebaseCoreWeb.registerService(
          'app-check',
          productNameOverride: 'app_check',
          ensurePluginInitialized: (firebaseApp) async {
            initializedAppNames.add(firebaseApp.name);
          },
        );

        expect(FirebaseCoreWeb.isServiceRegistered('app-check'), isTrue);

        const options = FirebaseOptions(
          apiKey: 'fake-api-key',
          appId: '1:1234567890:web:fake',
          messagingSenderId: '1234567890',
          projectId: 'fake-project',
          authDomain: 'fake-project.firebaseapp.com',
        );

        final coreWeb = FirebaseCoreWeb();
        final version = coreWeb.firebaseSDKVersion;
        await coreWeb.injectSrcScript(
          'https://www.gstatic.com/firebasejs/$version/firebase-app.js',
          'firebase_core',
        );

        await FirebasePlatform.instance.initializeApp(options: options);

        // Must still be registered so a secondary app can reactivate App Check.
        expect(FirebaseCoreWeb.isServiceRegistered('app-check'), isTrue);
        expect(initializedAppNames, contains('[DEFAULT]'));

        await FirebasePlatform.instance.initializeApp(
          name: 'prod',
          options: options,
        );

        expect(FirebaseCoreWeb.isServiceRegistered('app-check'), isTrue);
        expect(initializedAppNames, containsAll(['[DEFAULT]', 'prod']));
      },
    );
  });
}
