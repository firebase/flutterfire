// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
@TestOn('chrome')

import 'package:firebase_app_check_web/firebase_app_check_web.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockFirebaseAppCheck extends Mock implements FirebaseAppCheckWeb {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('$FirebaseAppCheckWeb', () {
    late MockFirebaseAppCheck appCheck;

    setUp(() {
      appCheck = MockFirebaseAppCheck();
    });

    test('instance', () {
      final appCheck = FirebaseAppCheckWeb.instance;

      expect(appCheck, isA<FirebaseAppCheckWeb>());
    });

    test('setInitialValues', () {
      appCheck.setInitialValues();
      verify(appCheck.setInitialValues());
      verifyNoMoreInteractions(appCheck);
    });

    test('activate', () async {
      await appCheck.activate(
        webRecaptchaSiteKey: 'key',
      );
      verify(appCheck.activate(webRecaptchaSiteKey: 'key'));
      verifyNoMoreInteractions(appCheck);
    });

    test('getToken', () async {
      await appCheck.getToken(true);
      verify(appCheck.getToken(true));
      verifyNoMoreInteractions(appCheck);
    });

    test('setTokenAutoRefreshEnabled', () async {
      await appCheck.setTokenAutoRefreshEnabled(true);
      verify(appCheck.setTokenAutoRefreshEnabled(true));
      verifyNoMoreInteractions(appCheck);
    });

    test('setTokenAutoRefreshEnabled', () async {
      appCheck.onTokenChange;
      verify(appCheck.onTokenChange);
      verifyNoMoreInteractions(appCheck);
    });
  });
}
