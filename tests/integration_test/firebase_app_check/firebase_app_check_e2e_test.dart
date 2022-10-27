// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tests/firebase_options.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group(
    'firebase_app_check',
    () {
      setUpAll(() async {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      });

      test('activate', () async {
        await expectLater(
          FirebaseAppCheck.instance.activate(
            webRecaptchaSiteKey: '6Lemcn0dAAAAABLkf6aiiHvpGD6x-zF3nOSDU2M8',
          ),
          completes,
        );
      });

      test(
        'getToken',
        () async {
          final token = await FirebaseAppCheck.instance.getToken(true);
          expect(token, isA<String>());
        },
        // Getting "Fetch server returned an HTTP error status. HTTP status:
        // 400" when running tests on web.
        //
        // Is not working on iOS and macOS. Tracking issue:
        // https://github.com/firebase/flutterfire/issues/8969
        skip: kIsWeb ||
            defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS,
      );

      test(
        'setTokenAutoRefreshEnabled',
        () async {
          await expectLater(
            FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true),
            completes,
          );
        },
      );

      test('onTokenChange', () async {
        final stream = FirebaseAppCheck.instance.onTokenChange;
        expect(stream, isA<Stream<String?>>());
      });
    },
  );
}
