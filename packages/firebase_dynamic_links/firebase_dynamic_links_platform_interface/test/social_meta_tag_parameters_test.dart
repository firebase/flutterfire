// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_dynamic_links_platform_interface/firebase_dynamic_links_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String description = 'description';
  String title = 'title';
  Uri imageUrl = Uri.parse('imageUrl');

  group('$SocialMetaTagParameters', () {
    SocialMetaTagParameters socialMetaTagParameters = SocialMetaTagParameters(
      description: description,
      title: title,
      imageUrl: imageUrl,
    );

    group('Constructor', () {
      test('returns an instance of [SocialMetaTagParameters]', () {
        expect(socialMetaTagParameters, isA<SocialMetaTagParameters>());
        expect(socialMetaTagParameters.description, description);
        expect(socialMetaTagParameters.title, title);
        expect(socialMetaTagParameters.imageUrl, imageUrl);
      });

      group('asMap', () {
        test('returns the current instance as a [Map]', () {
          final result = socialMetaTagParameters.asMap();

          expect(result, isA<Map<String, dynamic>>());
          expect(result['description'], socialMetaTagParameters.description);
          expect(result['title'], socialMetaTagParameters.title);
          expect(
            result['imageUrl'],
            socialMetaTagParameters.imageUrl.toString(),
          );
        });
      });

      test('toString', () {
        expect(
          socialMetaTagParameters.toString(),
          equals(
            '$SocialMetaTagParameters(${socialMetaTagParameters.asMap})',
          ),
        );
      });
    });
  });
}
