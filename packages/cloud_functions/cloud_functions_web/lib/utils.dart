// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:js_util' as util;

import 'package:cloud_functions_platform_interface/cloud_functions_platform_interface.dart';
import 'package:firebase_core_web/firebase_core_web_interop.dart' show dartify;

/// Given a web error, a [FirebaseFunctionsException] is returned.
FirebaseFunctionsException throwFirebaseFunctionsException(Object exception,
    [StackTrace? stackTrace]) {
  String originalCode = util.getProperty(exception, 'code');
  String code = originalCode.replaceFirst('functions/', '');
  String message = util
      .getProperty(exception, 'message')
      .replaceFirst('($originalCode)', '');

  return FirebaseFunctionsException(
      code: code,
      message: message,
      stackTrace: stackTrace,
      details: dartify(util.getProperty(exception, 'details')));
}
