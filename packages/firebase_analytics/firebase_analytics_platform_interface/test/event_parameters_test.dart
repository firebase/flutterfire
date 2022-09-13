// Copyright 2022 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_analytics_platform_interface/firebase_analytics_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EventParameters', () {
    group('EventParameters()', () {
      test('create EventParameters', () {
        EventParameters parameters = EventParameters();
        expect(parameters.asMap(), equals({}));
      });

      test('create EventParameters and use addParameters()', () {
        EventParameters parameters = EventParameters();
        parameters.addParameter('foo', string: 'bar');
        parameters.addParameter('num', number: 303);

        expect(parameters.asMap(), equals({'foo': 'bar', 'num': 303}));
      });

      test('should throw an AssertionError for incorrect use of addParameter()',
          () {
        EventParameters parameters = EventParameters();
        expect(() => parameters.addParameter('foo'), throwsAssertionError);
        expect(
          () => parameters.addParameter('foo', string: 'foo', number: 21.2),
          throwsAssertionError,
        );
      });
    });

    group(
      'EventParameters.fromMap()',
      () {
        test(
            'Create EventParameters using EventParameters.fromMap() with empty map',
            () {
          EventParameters parameters = EventParameters.fromMap({});

          expect(parameters.asMap(), equals({}));
        });

        test(
          'Create EventParameters using EventParameters.fromMap()',
          () {
            EventParameters parameters = EventParameters.fromMap(
              {'foo': 'bar', 'baz': 303},
            );

            expect(parameters.asMap(), equals({'foo': 'bar', 'baz': 303}));
          },
        );

        test(
          'should throw an AssertionError with incorrect use of EventParameters.fromMap()',
          () {
            expect(
              () => EventParameters.fromMap({'foo': true}),
              throwsAssertionError,
            );
            expect(
              () => EventParameters.fromMap({'foo': true, 'bar': 'baz'}),
              throwsAssertionError,
            );
            expect(
              () => EventParameters.fromMap({'foo': true, 'bar': 22}),
              throwsAssertionError,
            );
          },
        );
      },
    );
  });
}
