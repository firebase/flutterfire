// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_dynamic_links_platform_interface/firebase_dynamic_links_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  bool forcedRedirectEnabled = true;

  group('$NavigationInfoParameters', () {
    NavigationInfoParameters navParams =
        NavigationInfoParameters(forcedRedirectEnabled: forcedRedirectEnabled);

    group('Constructor', () {
      test('returns an instance of [NavigationInfoParameters]', () {
        expect(navParams, isA<NavigationInfoParameters>());
        expect(navParams.forcedRedirectEnabled, forcedRedirectEnabled);
      });

      group('asMap', () {
        test('returns the current instance as a [Map]', () {
          final result = navParams.asMap();

          expect(result, isA<Map<String, dynamic>>());
          expect(
            result['forcedRedirectEnabled'],
            navParams.forcedRedirectEnabled,
          );
        });
      });

      test('toString', () {
        expect(
          navParams.toString(),
          equals('$NavigationInfoParameters(${navParams.asMap})'),
        );
      });
    });
  });
}
