// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:_flutterfire_internals/_flutterfire_internals.dart';
import 'package:flutter_test/flutter_test.dart';

// The JS error mapping is tested in `firebase_core_js`, which owns it.
void main() {
  group('guardWebException', () {
    test('returns the callback result', () async {
      expect(
        guardWebExceptions(() => 42, plugin: 'test', codeParser: (c) => c),
        42,
      );
      expect(
        await guardWebExceptions(
          () => Future.value(42),
          plugin: 'test',
          codeParser: (c) => c,
        ),
        42,
      );
    });

    test(
      'propagates plain Dart errors from Futures (e.g. ArgumentError on web)',
      () async {
        await expectLater(
          guardWebExceptions(
            () => Future<void>.error(ArgumentError('test')),
            plugin: 'test',
            codeParser: (c) => c,
          ),
          throwsA(isA<ArgumentError>()),
        );
      },
    );
  });
}
