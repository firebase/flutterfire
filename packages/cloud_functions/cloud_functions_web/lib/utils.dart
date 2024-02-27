// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:cloud_functions_platform_interface/cloud_functions_platform_interface.dart';

/// Given a web error, a [FirebaseFunctionsException] is returned.
FirebaseFunctionsException convertFirebaseFunctionsException(JSObject exception,
    [StackTrace? stackTrace]) {
  String originalCode =
      (exception.getProperty('code'.toJS)! as JSString).toDart;
  String code = originalCode.replaceFirst('functions/', '');
  String message = (exception.getProperty('message'.toJS)! as JSString)
      .toDart
      .replaceFirst('($originalCode)', '');

  return FirebaseFunctionsException(
    code: code,
    message: message,
    stackTrace: stackTrace,
    details: exception.getProperty('details'.toJS)?.dartify(),
  );
}
