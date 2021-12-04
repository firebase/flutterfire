// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_dynamic_links_platform_interface/firebase_dynamic_links_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Uri link = Uri.parse('short-link');
  Uri previewLink = Uri.parse('preview-link');
  List<String> warnings = ['warning'];

  group('$ShortDynamicLink', () {
    ShortDynamicLink shortLink = ShortDynamicLink(
      type: ShortDynamicLinkType.short,
      shortUrl: link,
      previewLink: previewLink,
      warnings: warnings,
    );

    group('Constructor', () {
      test('returns an instance of [ShortDynamicLink]', () {
        expect(shortLink, isA<ShortDynamicLink>());
        expect(shortLink.shortUrl, link);
        expect(shortLink.type, ShortDynamicLinkType.short);
        expect(shortLink.previewLink, previewLink);
        expect(shortLink.warnings, warnings);
      });

      group('asMap', () {
        test('returns the current instance as a [Map]', () {
          final result = shortLink.asMap();

          expect(result, isA<Map<String, dynamic>>());
          expect(result['shortUrl'], shortLink.shortUrl.toString());
          expect(result['previewLink'], shortLink.previewLink.toString());
          expect(result['warnings'], shortLink.warnings);
        });
      });

      test('toString', () {
        expect(
          shortLink.toString(),
          equals(
            '$ShortDynamicLink(${shortLink.asMap})',
          ),
        );
      });
    });
  });
}
