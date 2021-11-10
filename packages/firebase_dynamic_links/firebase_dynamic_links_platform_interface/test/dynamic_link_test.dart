// ignore_for_file: require_trailing_commas
// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_dynamic_links_platform_interface/src/dynamic_link.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Uri link = Uri.parse('dynamicLink');

  group('$DynamicLink', () {
    DynamicLink dynamicLink = DynamicLink(url: link);
    group('Constructor', () {
      test('returns an instance of [DynamicLink]', () {
        expect(dynamicLink, isA<DynamicLink>());
        expect(dynamicLink.url, link);
      });

      group('asMap', () {
        test('returns the current instance as a [Map]', () {
          final result = dynamicLink.asMap();

          expect(result, isA<Map<String, dynamic>>());
          expect(result['url'], link.toString());
        });
      });

      test('toString', () {
        expect(dynamicLink.toString(),
            equals('$DynamicLink(${dynamicLink.asMap})'));
      });
    });
  });
}
