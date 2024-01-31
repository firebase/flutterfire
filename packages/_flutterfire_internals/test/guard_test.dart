// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:js_interop';

import 'package:_flutterfire_internals/_flutterfire_internals.dart';
import 'package:_flutterfire_internals/src/interop_shimmer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('guardWebException', () {
    test('preserves stacktrace on futures that fail with FirebaseError',
        () async {
      final current = StackTrace.current;
      try {
        await guardWebExceptions(
          () => Future.error(_FirebaseError(), current),
          plugin: 'test',
          codeParser: (c) => c,
        );
        fail('dead code');
      } catch (err, stack) {
        expect(stack, current);
      }
    });

    test('preserves stacktrace on streams that fail with FirebaseError',
        () async {
      final current = StackTrace.current;
      try {
        await guardWebExceptions(
          () => Stream.error(_FirebaseError(), current),
          plugin: 'test',
          codeParser: (c) => c,
        ).first;
        fail('dead code');
      } catch (err, stack) {
        expect(stack, current);
      }
    });

    test('preserves stacktrace on functions that throw a FirebaseError',
        () async {
      final current = StackTrace.current;
      try {
        guardWebExceptions<void>(
          () => Error.throwWithStackTrace(_FirebaseError(), current),
          plugin: 'test',
          codeParser: (c) => c,
        );
        fail('dead code');
      } catch (err, stack) {
        expect(stack, current);
      }
    });
  });
}

class _FirebaseError implements FirebaseError {
  @override
  JSString get code => ''.toJS;

  @override
  JSString get message => ''.toJS;

  @override
  JSString get name => ''.toJS;

  @override
  JSString get serverResponse => ''.toJS;

  @override
  JSString get stack => ''.toJS;
}
