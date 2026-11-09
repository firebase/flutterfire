// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:cloud_functions_platform_interface/cloud_functions_platform_interface.dart';

/// Whether [error] is a JS error from the Functions SDK, that is a JS object
/// with a string `code`.
///
/// Dart errors and other JS errors return `false` and should be rethrown
/// as they are.
bool isFirebaseFunctionsError(Object? error) {
  // `is JSObject` is false for Dart objects on both dart2js and dart2wasm.
  // ignore: invalid_runtime_check_with_js_interop_types
  return error is JSObject && error.getProperty('code'.toJS).isA<JSString>();
}

/// Returns the string value of [property] on [object], or `null`.
String? _stringProperty(JSObject object, String property) {
  final value = object.getProperty(property.toJS);
  return value.isA<JSString>() ? (value! as JSString).toDart : null;
}

/// Given a web error, a [FirebaseFunctionsException] is returned.
FirebaseFunctionsException convertFirebaseFunctionsException(
  JSObject exception, [
  StackTrace? stackTrace,
]) {
  String originalCode = _stringProperty(exception, 'code') ?? 'unknown';
  String code = originalCode.replaceFirst('functions/', '');
  String message = (_stringProperty(exception, 'message') ?? '').replaceFirst(
    '($originalCode)',
    '',
  );

  return FirebaseFunctionsException(
    code: code,
    message: message,
    stackTrace: stackTrace,
    details: exception.getProperty('details'.toJS)?.dartify(),
  );
}
