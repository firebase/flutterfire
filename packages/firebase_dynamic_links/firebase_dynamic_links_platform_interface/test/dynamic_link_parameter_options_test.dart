// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_dynamic_links_platform_interface/firebase_dynamic_links_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('$DynamicLinkParametersOptions', () {
    DynamicLinkParametersOptions dynamicLinkOptions =
        const DynamicLinkParametersOptions(
      shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
    );
    group('Constructor', () {
      test('returns an instance of [DynamicLinkParametersOptions]', () {
        expect(dynamicLinkOptions, isA<DynamicLinkParametersOptions>());
        expect(
          dynamicLinkOptions.shortDynamicLinkPathLength,
          ShortDynamicLinkPathLength.short,
        );
      });

      group('asMap', () {
        test('returns the current instance as a [Map]', () {
          final result = dynamicLinkOptions.asMap();

          expect(result, isA<Map<String, dynamic>>());
          expect(
            result['shortDynamicLinkPathLength'],
            ShortDynamicLinkPathLength.short.index,
          );
        });
      });

      test('toString', () {
        expect(
          dynamicLinkOptions.toString(),
          equals(
            '$DynamicLinkParametersOptions(${dynamicLinkOptions.asMap})',
          ),
        );
      });
    });
  });
}
