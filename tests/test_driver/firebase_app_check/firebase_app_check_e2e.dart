// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_app_check/firebase_app_check.dart';

import 'package:drive/drive.dart';
import '../firebase_default_options.dart';
// import 'package:flutter/foundation.dart';

// TODO RTDB emulator breaks just by including App Check
void setupTests() {
  group(
    'firebase_app_check',
    () {
      setUpAll(() async {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      });

      // test('activate', () async {
      //   await expectLater(
      //     FirebaseAppCheck.instance.activate(
      //       webRecaptchaSiteKey: '6Lemcn0dAAAAABLkf6aiiHvpGD6x-zF3nOSDU2M8',
      //     ),
      //     completes,
      //   );
      // });

      // test(
      //   'getToken',
      //   () async {
      //     final token = await FirebaseAppCheck.instance.getToken(true);
      //     expect(token, isA<String?>());
      //   },
      //   // TODO why is this Android/Web only?
      //   skip: defaultTargetPlatform == TargetPlatform.iOS ||
      //       defaultTargetPlatform == TargetPlatform.macOS,
      // );

      // test(
      //   'setTokenAutoRefreshEnabled',
      //   () async {
      //     await expectLater(
      //       FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true),
      //       completes,
      //     );
      //   },
      // );

      // test('tokenChanges', () async {
      //   final stream = FirebaseAppCheck.instance.onTokenChange;
      //   expect(stream, isA<Stream>());

      //   // TODO how to trigger event listener in e2e tests?
      //   // await FirebaseAppCheck.instance.getToken(true);
      //   //
      //   // final result = await stream.first;
      //   //
      //   // expect(result, isA<AppCheckTokenResult>());
      //   // expect(result.token, isA<String>());
      // });
    },
  );
}
