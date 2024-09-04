// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: require_trailing_commas
// DO NOT MOVE THIS FILE
//
// Other firebase packages may import `package:firebase_core/src/internals.dart`.
// Moving it would break the imports
//
// This file exports utilities shared between firebase packages, without making
// them public.

import 'package:firebase_core/firebase_core.dart';

import 'src/interop_shimmer.dart'
    if (dart.library.js_interop) 'package:firebase_core_web/firebase_core_web_interop.dart'
    as core_interop;
import 'src/interop_shimmer.dart'
    if (dart.library.js_interop) 'src/js_interop.dart' as js_interop;

export 'src/exception.dart';

/// An extension that adds utilities for safely casting objects
extension ObjectX<T> on T? {
  /// Transform an object if that value is not null.
  ///
  /// Doing:
  ///
  /// ```dart
  /// Map? json;
  /// var result = json?['key']?.guard((json) => Model.fromJson(json));
  /// ```
  ///
  /// is equivalent to doing:
  ///
  /// ```dart
  /// Map? json;
  /// var key = json?['key'];
  /// var result = key == null ? null : Model.fromJson(key);
  /// ```
  R? guard<R>(R Function(T value) cb) {
    if (this is T) return cb(this as T);
    return null;
  }

  /// Safely cast an object, returning `null` if the casted object does not
  /// match the casted type.
  R? safeCast<R>() {
    if (this is R) return this as R;
    return null;
  }
}

// Necessary because of the conditional import
String _safeConvertFromPossibleJSObject(dynamic value) {
  if (value is js_interop.JSAny) {
    return (value as js_interop.JSString).toDart;
  } else {
    return value as String;
  }
}

FirebaseException _firebaseExceptionFromCoreFirebaseError(
  core_interop.JSError firebaseError, {
  required String plugin,
  required String Function(String) codeParser,
  required String Function(String code, String message)? messageParser,
}) {
  final convertCode = _safeConvertFromPossibleJSObject(firebaseError.code);
  final code = codeParser(convertCode);

  final String convertMessage =
      _safeConvertFromPossibleJSObject(firebaseError.message);
  final message = messageParser != null
      ? messageParser(code, convertMessage)
      : convertMessage.replaceFirst('(${firebaseError.code})', '');

  return FirebaseException(
    plugin: plugin,
    message: message,
    code: code,
  );
}

/// Checks whether a thrown object needs to be mapped using [_mapException] or
/// should be left untouched.
///
/// It is critical to split [_testException] and [_mapException] so that
/// exceptions that should not be transformed preserve their stracktrace.
///
/// See also https://github.com/dart-lang/sdk/issues/30741
bool _testException(Object? objectException) {
  final exception = objectException! as core_interop.JSError;

  final message = _safeConvertFromPossibleJSObject(exception.message);
  // Firestore web does not contain `Firebase` in the message so we check the exception itself.
  return message.contains('Firebase') ||
      exception.toString().contains('FirebaseError');
}

/// Transforms internal errors in something more readable for end-users.
Object _mapException(
  Object? exception, {
  required String plugin,
  required String Function(String) codeParser,
  required String Function(String code, String message)? messageParser,
}) {
  assert(_testException(exception));

  if (exception is core_interop.JSError) {
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
      ) as R;
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
      ) as R;
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
