// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('browser')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:firebase_core_interface/firebase_core_interface.dart';
import 'package:firebase_core_js/firebase_core_js_interop.dart';
import 'package:test/test.dart';

/// A JS `Error` shaped like the ones the Firebase JS SDK throws.
JSObject _firebaseError() {
  final error = (globalContext['Error']! as JSFunction)
      .callAsConstructor<JSObject>(
        'Firebase: Missing or insufficient permissions. (test/permission-denied).'
            .toJS,
      );
  error['name'] = 'FirebaseError'.toJS;
  error['code'] = 'test/permission-denied'.toJS;
  return error;
}

String _codeParser(String code) => code.split('/').last;

final _expectedException = isA<FirebaseException>()
    .having((e) => e.plugin, 'plugin', 'test')
    .having((e) => e.code, 'code', 'permission-denied')
    .having(
      (e) => e.message,
      'message',
      'Firebase: Missing or insufficient permissions. .',
    );

void main() {
  group('guardWebExceptions', () {
    test('maps a thrown FirebaseError and keeps its stack trace', () {
      final current = StackTrace.current;
      try {
        guardWebExceptions<void>(
          () => Error.throwWithStackTrace(_firebaseError(), current),
          plugin: 'test',
          codeParser: _codeParser,
        );
        fail('dead code');
      } catch (err, stack) {
        expect(err, _expectedException);
        expect(stack.toString(), current.toString());
      }
    });

    test(
      'maps a FirebaseError from a Future and keeps its stack trace',
      () async {
        final current = StackTrace.current;
        try {
          await guardWebExceptions(
            () => Future<void>.error(_firebaseError(), current),
            plugin: 'test',
            codeParser: _codeParser,
          );
          fail('dead code');
        } catch (err, stack) {
          expect(err, _expectedException);
          expect(stack.toString(), current.toString());
        }
      },
    );

    test(
      'maps a FirebaseError from a Stream and keeps its stack trace',
      () async {
        final current = StackTrace.current;
        try {
          await guardWebExceptions(
            () => Stream<void>.error(_firebaseError(), current),
            plugin: 'test',
            codeParser: _codeParser,
          ).first;
          fail('dead code');
        } catch (err, stack) {
          expect(err, _expectedException);
          expect(stack.toString(), current.toString());
        }
      },
    );

    test('uses messageParser when given', () async {
      await expectLater(
        guardWebExceptions(
          () => Future<void>.error(_firebaseError()),
          plugin: 'test',
          codeParser: _codeParser,
          messageParser: (code, message) => 'parsed $code',
        ),
        throwsA(
          isA<FirebaseException>().having(
            (e) => e.message,
            'message',
            'parsed permission-denied',
          ),
        ),
      );
    });

    test('propagates other JS errors unchanged', () async {
      final error = (globalContext['Error']! as JSFunction)
          .callAsConstructor<JSObject>('boom'.toJS);
      await expectLater(
        guardWebExceptions(
          () => Future<void>.error(error),
          plugin: 'test',
          codeParser: _codeParser,
        ),
        throwsA(same(error)),
      );
    });

    test('propagates JS values without a message unchanged', () async {
      final error = JSObject();
      await expectLater(
        guardWebExceptions(
          () => Future<void>.error(error),
          plugin: 'test',
          codeParser: _codeParser,
        ),
        throwsA(same(error)),
      );
    });

    test('maps a Firebase JS error without a code', () async {
      final error = (globalContext['Error']! as JSFunction)
          .callAsConstructor<JSObject>('Firebase: no code.'.toJS);
      await expectLater(
        guardWebExceptions(
          () => Future<void>.error(error),
          plugin: 'test',
          codeParser: _codeParser,
        ),
        throwsA(
          isA<FirebaseException>()
              .having((e) => e.code, 'code', '')
              .having((e) => e.message, 'message', 'Firebase: no code.'),
        ),
      );
    });

    test('propagates Dart errors unchanged', () async {
      await expectLater(
        guardWebExceptions(
          () => Future<void>.error(ArgumentError('test')),
          plugin: 'test',
          codeParser: _codeParser,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
