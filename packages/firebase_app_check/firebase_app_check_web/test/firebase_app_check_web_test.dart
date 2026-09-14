// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
@TestOn('chrome')
import 'package:firebase_app_check_platform_interface/firebase_app_check_platform_interface.dart';
import 'package:firebase_app_check_web/firebase_app_check_web.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<FirebaseAppCheckWeb>()])
import 'firebase_app_check_web_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('$FirebaseAppCheckWeb', () {
    late MockFirebaseAppCheckWeb appCheck;

    setUp(() {
      appCheck = MockFirebaseAppCheckWeb();
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

    test('activate with ReCaptchaV3Provider', () async {
      final provider = ReCaptchaV3Provider('key');
      await appCheck.activate(
        webProvider: provider,
      );
      verify(
        appCheck.activate(
          webProvider: provider,
        ),
      );
      verifyNoMoreInteractions(appCheck);
    });

    test('activate with ReCaptchaEnterpriseProvider', () async {
      final provider = ReCaptchaEnterpriseProvider('key');
      await appCheck.activate(
        webProvider: provider,
      );
      verify(
        appCheck.activate(
          webProvider: provider,
        ),
      );
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
