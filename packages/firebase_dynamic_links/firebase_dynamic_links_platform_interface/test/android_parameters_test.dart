// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_dynamic_links_platform_interface/firebase_dynamic_links_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Uri fallbackUrl = Uri.parse('fallbackUrl');
  const String packageName = 'packageName';
  const int minimumVersion = 21;

  group('$AndroidParameters', () {
    AndroidParameters androidParams = AndroidParameters(
      fallbackUrl: fallbackUrl,
      minimumVersion: minimumVersion,
      packageName: packageName,
    );
    group('Constructor', () {
      test('returns an instance of [AndroidParameters]', () {
        expect(androidParams, isA<AndroidParameters>());
        expect(androidParams.fallbackUrl, fallbackUrl);
        expect(androidParams.minimumVersion, minimumVersion);
        expect(androidParams.packageName, packageName);
      });

      group('asMap', () {
        test('returns the current instance as a [Map]', () {
          final result = androidParams.asMap();

          expect(result, isA<Map<String, dynamic>>());

          expect(result['fallbackUrl'], fallbackUrl.toString());
          expect(result['minimumVersion'], minimumVersion);
          expect(result['packageName'], packageName);
        });
      });

      test('toString', () {
        expect(
          androidParams.toString(),
          equals('$AndroidParameters(${androidParams.asMap})'),
        );
      });
    });
  });
}
