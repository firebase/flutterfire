// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('browser')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:cloud_functions_platform_interface/cloud_functions_platform_interface.dart';
import 'package:cloud_functions_web/https_callable_web.dart';
import 'package:cloud_functions_web/interop/functions.dart'
    as functions_interop;
import 'package:cloud_functions_web/interop/functions_interop.dart'
    show FunctionsJsImpl;
import 'package:flutter_test/flutter_test.dart';

class _FakeFunctions extends FirebaseFunctionsPlatform {
  _FakeFunctions() : super(null, 'us-central1');
}

/// A JS error shaped like the `FunctionsError` the JS SDK rejects with.
JSObject _functionsError() {
  final error = (globalContext['Error']! as JSFunction)
      .callAsConstructor<JSObject>('not allowed'.toJS);
  error['name'] = 'FirebaseError'.toJS;
  error['code'] = 'functions/permission-denied'.toJS;
  error['details'] = {'reason': 'quota'}.jsify();
  return error;
}

JSPromise _rejectWith(JSAny error) => (globalContext['Promise']! as JSObject)
    .callMethod<JSPromise>('reject'.toJS, error);

/// Matches the exact JS value [expected], not a wrapper around it.
Matcher _isJsValue(JSAny expected) => predicate<Object>(
  // ignore: invalid_runtime_check_with_js_interop_types
  (e) => e is JSObject && e.strictEquals(expected).toDart,
  'is the original JS error',
);

void main() {
  /// Points the JS SDK's `httpsCallable()` at [callable].
  HttpsCallableWeb callableReturning(
    JSFunction callable, {
    HttpsCallableOptions? options,
  }) {
    final sdk = JSObject();
    // `stream()` calls `httpsCallable()` without options, `call()` with them.
    sdk['httpsCallable'] =
        ((JSAny? functions, JSAny? name, [JSAny? options]) => callable).toJS;
    globalContext['firebase_functions'] = sdk;

    return HttpsCallableWeb(
      _FakeFunctions(),
      functions_interop.Functions.getInstance(JSObject() as FunctionsJsImpl),
      null,
      'fn',
      options ?? HttpsCallableOptions(),
      null,
    );
  }

  /// A callable whose `call()` and `stream()` both run [onCall].
  JSFunction callable(JSAny? Function() onCall) {
    final fn = ((JSAny? data) => onCall()).toJS;
    fn['stream'] = ((JSAny? data, JSAny? options) => onCall()).toJS;
    return fn;
  }

  group('call()', () {
    test('maps a FunctionsError to FirebaseFunctionsException', () async {
      final web = callableReturning(
        callable(() => _rejectWith(_functionsError())),
      );

      await expectLater(
        web.call(),
        throwsA(
          isA<FirebaseFunctionsException>()
              .having((e) => e.code, 'code', 'permission-denied')
              .having((e) => e.message, 'message', 'not allowed')
              .having((e) => e.details, 'details', {'reason': 'quota'}),
        ),
      );
    });

    test('rethrows a JS rejection that has no code or message', () async {
      final error = JSObject();
      final web = callableReturning(callable(() => _rejectWith(error)));

      await expectLater(web.call(), throwsA(_isJsValue(error)));
    });

    test('rethrows a plain JS Error that has no code', () async {
      final error = (globalContext['Error']! as JSFunction)
          .callAsConstructor<JSObject>('network down'.toJS);
      final web = callableReturning(callable(() => _rejectWith(error)));

      await expectLater(web.call(), throwsA(_isJsValue(error)));
    });

    test('rethrows a Dart error unchanged', () async {
      final web = callableReturning(callable(() => throw StateError('boom')));

      await expectLater(
        web.call(),
        throwsA(isA<StateError>().having((e) => e.message, 'message', 'boom')),
      );
    });
  });

  group('stream()', () {
    test('maps a FunctionsError to FirebaseFunctionsException', () async {
      final web = callableReturning(
        callable(() => _rejectWith(_functionsError())),
      );

      await expectLater(
        web.stream(null),
        emitsError(
          isA<FirebaseFunctionsException>().having(
            (e) => e.code,
            'code',
            'permission-denied',
          ),
        ),
      );
    });

    test('rethrows a JS rejection that has no code or message', () async {
      final error = JSObject();
      final web = callableReturning(callable(() => _rejectWith(error)));

      await expectLater(web.stream(null), emitsError(_isJsValue(error)));
    });

    test('rethrows a Dart error unchanged', () async {
      final web = callableReturning(callable(() => throw StateError('boom')));

      await expectLater(web.stream(null), emitsError(isA<StateError>()));
    });

    test('rethrows the error from an invalid abort signal', () async {
      // `AbortSignal.timeout()` rejects a negative delay with a JS TypeError.
      final web = callableReturning(
        callable(() => _rejectWith(_functionsError())),
        options: HttpsCallableOptions(
          webAbortSignal: TimeLimit(const Duration(milliseconds: -1)),
        ),
      );

      await expectLater(
        web.stream(null),
        emitsError(
          predicate<Object>(
            (e) => e.toString().contains('AbortSignal'),
            'is the original AbortSignal error',
          ),
        ),
      );
    });
  });
}
