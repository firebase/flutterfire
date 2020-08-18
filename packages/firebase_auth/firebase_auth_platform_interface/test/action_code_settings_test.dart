// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final String kMockBundleId = 'com.test.bundle';
  final String kMockPackageName = 'com.test.package';

  final String kMockDynamicLinkDomain = 'domain.com';
  final bool kMockHandleCodeInApp = true;
  final String kMockUrl = 'https://test.url';
  final String kMockMinimumVersion = '8.0';
  final Map<String, dynamic> kMockInstallApp = <String, dynamic>{};

  final Map<String, dynamic> kMockAndroid = <String, dynamic>{
    'packageName': kMockPackageName,
    'installApp': kMockInstallApp,
    'minimumVersion': kMockMinimumVersion,
  };
  final Map<String, dynamic> kMockIOS = <String, dynamic>{
    'bundleId': kMockBundleId
  };

  group('$ActionCodeSettings', () {
    ActionCodeSettings actionCodeSettings = ActionCodeSettings(
        android: kMockAndroid,
        dynamicLinkDomain: kMockDynamicLinkDomain,
        handleCodeInApp: kMockHandleCodeInApp,
        iOS: kMockIOS,
        url: kMockUrl);
    group('Constructor', () {
      test('returns an instance of [ActionCodeInfo]', () {
        expect(actionCodeSettings, isA<ActionCodeSettings>());
        expect(actionCodeSettings.url, equals(kMockUrl));
        expect(actionCodeSettings.dynamicLinkDomain,
            equals(kMockDynamicLinkDomain));
        expect(
            actionCodeSettings.handleCodeInApp, equals(kMockHandleCodeInApp));
        expect(actionCodeSettings.android, equals(kMockAndroid));
        expect(actionCodeSettings.android['packageName'],
            equals(kMockPackageName));
        expect(actionCodeSettings.iOS, equals(kMockIOS));
        expect(actionCodeSettings.iOS['bundleId'], equals(kMockBundleId));
      });
      test('throws [AssertionError] when url is null', () {
        expect(() => ActionCodeSettings(url: null), throwsAssertionError);
      });

      test('throws [AssertionError] when android.packageName is null', () {
        expect(
            () => ActionCodeSettings(
                url: kMockUrl, android: <String, dynamic>{'packageName': null}),
            throwsAssertionError);
      });

      test('throws [AssertionError] when iOS.bundleId is null', () {
        expect(
            () => ActionCodeSettings(
                url: kMockUrl,
                android: kMockAndroid,
                iOS: <String, dynamic>{'bundleId': null}),
            throwsAssertionError);
      });
    });

    group('asMap', () {
      test('returns the current instance as a [Map]', () {
        final result = actionCodeSettings.asMap();

        expect(result, isA<Map<String, dynamic>>());

        expect(result['url'], equals(kMockUrl));
        expect(result['dynamicLinkDomain'], equals(kMockDynamicLinkDomain));
        expect(result['handleCodeInApp'], equals(kMockHandleCodeInApp));
        expect(result['android'], equals(kMockAndroid));
        expect(result['android']['packageName'], equals(kMockPackageName));
        expect(result['android']['installApp'], equals(kMockInstallApp));
        expect(
            result['android']['minimumVersion'], equals(kMockMinimumVersion));
        expect(result['iOS'], equals(kMockIOS));
        expect(result['iOS']['bundleId'], equals(kMockBundleId));
      });

      test('sets android to null', () {
        ActionCodeSettings testActionCodeSettings =
            ActionCodeSettings(url: kMockUrl, android: null, iOS: kMockIOS);

        final result = testActionCodeSettings.asMap();

        expect(result, isA<Map<String, dynamic>>());

        expect(result['android'], isNull);
      });

      test('sets iOS to null', () {
        ActionCodeSettings testActionCodeSettings =
            ActionCodeSettings(url: kMockUrl, android: kMockAndroid, iOS: null);

        final result = testActionCodeSettings.asMap();

        expect(result, isA<Map<String, dynamic>>());

        expect(result['iOS'], isNull);
      });
    });

    test('toString', () {
      expect(actionCodeSettings.toString(),
          equals('$ActionCodeSettings(${actionCodeSettings.asMap})'));
    });
  });
}
