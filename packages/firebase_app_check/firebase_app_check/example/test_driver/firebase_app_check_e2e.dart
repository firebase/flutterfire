// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'dart:io';

import 'package:drive/drive.dart' as drive;
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_app_check_platform_interface/firebase_app_check_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

void testsMain() {
  group('$FirebaseAppCheck', () {
    final FirebaseAppCheck appCheck = FirebaseAppCheck.instance;

    setUpAll(() async {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyAHAsf51D0A407EklG1bs-5wA7EbyfNFg0',
          appId: '1:448618578101:ios:2bc5c1fe2ec336f8ac3efc',
          storageBucket: 'react-native-firebase-testing.appspot.com',
          databaseURL: 'https://react-native-firebase-testing.firebaseio.com',
          messagingSenderId: '448618578101',
          projectId: 'react-native-firebase-testing',
        ),
      );
    });

    test('activate', () async {
      await expectLater(
        appCheck.activate(
          webRecaptchaSiteKey: '6Lemcn0dAAAAABLkf6aiiHvpGD6x-zF3nOSDU2M8',
        ),
        completes,
      );
    });

    test(
      'getToken',
      () async {
        AppCheckTokenResult result = await appCheck.getToken(true);

        expect(result, isA<AppCheckTokenResult>());
        expect(result.token, isA<String>());
      },
      skip: Platform.isIOS,
    );

    test(
      'setTokenAutoRefreshEnabled',
      () async {
        await expectLater(
          appCheck.setTokenAutoRefreshEnabled(true),
          completes,
        );
      },
    );

    test('tokenChanges', () async {
      final stream = appCheck.tokenChanges();

      expect(stream, isA<Stream>());

      // TODO how to trigger event listener
      // await appCheck.getToken(true);
      //
      // final result = await stream.first;
      //
      // expect(result, isA<AppCheckTokenResult>());
      // expect(result.token, isA<String>());
    });
  });
}

void main() => drive.main(testsMain);
