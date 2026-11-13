// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:js_interop';

import 'package:firebase_core_interface/firebase_core_interface.dart';

import 'interop/utils/es6_interop.dart';

// Moved from `_flutterfire_internals`, which re-exports it.

// `JSError` is erased at runtime, so `is JSError` matches any JS object, and
// `message` or `code` may be missing.
String _toDart(JSString? value) => value?.toDart ?? '';

FirebaseException _firebaseExceptionFromCoreFirebaseError(
  JSError firebaseError, {
  required String plugin,
  required String Function(String) codeParser,
  required String Function(String code, String message)? messageParser,
}) {
  final rawCode = _toDart(firebaseError.code);
  final code = codeParser(rawCode);

  final rawMessage = _toDart(firebaseError.message);
  final message = messageParser != null
      ? messageParser(code, rawMessage)
      : rawMessage.replaceFirst('($rawCode)', '');

  return FirebaseException(plugin: plugin, message: message, code: code);
}

/// Checks whether a thrown object needs to be mapped using [_mapException] or
/// should be left untouched.
///
/// It is critical to split [_testException] and [_mapException] so that
/// exceptions that should not be transformed preserve their stracktrace.
///
/// See also https://github.com/dart-lang/sdk/issues/30741
bool _testException(Object? objectException) {
  // isA on Object requires Dart 3.12; this package supports 3.10.
  // ignore: invalid_runtime_check_with_js_interop_types
  if (objectException is! JSError) {
    return false;
  }

  final message = _toDart(objectException.message);
  // Firestore web does not contain `Firebase` in the message so we check the exception itself.
  return message.contains('Firebase') ||
      objectException.toString().contains('FirebaseError');
}

/// Transforms internal errors in something more readable for end-users.
Object _mapException(
  Object? exception, {
  required String plugin,
  required String Function(String) codeParser,
  required String Function(String code, String message)? messageParser,
}) {
  assert(_testException(exception));

  // ignore: invalid_runtime_check_with_js_interop_types
  if (exception is JSError) {
    return _firebaseExceptionFromCoreFirebaseError(
      exception,
      plugin: plugin,
      codeParser: codeParser,
      messageParser: messageParser,
    );
  }

  throw StateError('unrecognized error $exception');
}

/// Will return a [FirebaseException] from a thrown web error.
/// Any other errors will be propagated as normal.
R guardWebExceptions<R>(
  R Function() cb, {
  required String plugin,
  required String Function(String) codeParser,
  String Function(String code, String message)? messageParser,
}) {
  try {
    final value = cb();

    if (value is Future) {
      return value.catchError(
            (err, stack) => Error.throwWithStackTrace(
              _mapException(
                err,
                plugin: plugin,
                codeParser: codeParser,
                messageParser: messageParser,
              ),
              stack,
            ),
            test: _testException,
          )
          as R;
    } else if (value is Stream) {
      return value.handleError(
            (err, stack) => Error.throwWithStackTrace(
              _mapException(
                err,
                plugin: plugin,
                codeParser: codeParser,
                messageParser: messageParser,
              ),
              stack,
            ),
            test: _testException,
          )
          as R;
    }

    return value;
  } catch (error, stack) {
    if (!_testException(error)) {
      // Make sure to preserve the stacktrace
      rethrow;
    }

    Error.throwWithStackTrace(
      _mapException(
        error,
        plugin: plugin,
        codeParser: codeParser,
        messageParser: messageParser,
      ),
      stack,
    );
  }
}
