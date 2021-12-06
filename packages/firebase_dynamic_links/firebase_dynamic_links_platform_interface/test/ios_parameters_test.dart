// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_dynamic_links_platform_interface/firebase_dynamic_links_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String appStoreId = 'appStoreId';
  String bundleId = 'bundleId';
  String customScheme = 'customScheme';
  String ipadBundleId = 'ipadBundleId';
  String minimumVersion = 'minimumVersion';
  Uri fallbackUrl = Uri.parse('fallbackUrl');
  Uri ipadFallbackUrl = Uri.parse('ipadFallbackUrl');

  group('$IOSParameters', () {
    IOSParameters iosParams = IOSParameters(
      appStoreId: appStoreId,
      bundleId: bundleId,
      customScheme: customScheme,
      fallbackUrl: fallbackUrl,
      ipadBundleId: ipadBundleId,
      ipadFallbackUrl: ipadFallbackUrl,
      minimumVersion: minimumVersion,
    );

    group('Constructor', () {
      test('returns an instance of [IosParameters]', () {
        expect(iosParams, isA<IOSParameters>());
        expect(iosParams.appStoreId, appStoreId);
        expect(iosParams.bundleId, bundleId);
        expect(iosParams.bundleId, bundleId);
        expect(iosParams.customScheme, customScheme);
        expect(iosParams.fallbackUrl, fallbackUrl);
        expect(iosParams.ipadBundleId, ipadBundleId);
        expect(iosParams.ipadFallbackUrl, ipadFallbackUrl);
        expect(iosParams.minimumVersion, minimumVersion);
      });

      group('asMap', () {
        test('returns the current instance as a [Map]', () {
          final result = iosParams.asMap();

          expect(result, isA<Map<String, dynamic>>());
          expect(result['appStoreId'], iosParams.appStoreId);
          expect(result['bundleId'], iosParams.bundleId);
          expect(result['customScheme'], iosParams.customScheme);
          expect(result['fallbackUrl'], iosParams.fallbackUrl.toString());
          expect(
            result['ipadFallbackUrl'],
            iosParams.ipadFallbackUrl.toString(),
          );
          expect(result['ipadBundleId'], iosParams.ipadBundleId);
          expect(result['minimumVersion'], iosParams.minimumVersion);
        });
      });

      test('toString', () {
        expect(
          iosParams.toString(),
          equals('$IOSParameters(${iosParams.asMap})'),
        );
      });
    });
  });
}
