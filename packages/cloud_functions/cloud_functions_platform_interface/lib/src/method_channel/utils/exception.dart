// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import '../../../cloud_functions_platform_interface.dart';

/// Catches a [PlatformException] and converts it into a [FirebaseFunctionsException]
/// if it was intentionally caught on the native platform.
FutureOr<Map<String, dynamic>> catchPlatformException(Object exception,
    [StackTrace? stackTrace]) async {
  if (exception is! Exception || exception is! PlatformException) {
    // TODO(Salakar): Is this dead code?
    // ignore: only_throw_errors
    throw exception;
  }

  throw platformExceptionToFirebaseFunctionsException(exception, stackTrace);
}

/// Converts a [PlatformException] into a [FirebaseFunctionsException].
///
/// A [PlatformException] can only be converted to a [FirebaseFunctionsException] if
/// the `details` of the exception exist. Firebase returns specific codes and
/// messages which can be converted into user friendly exceptions.
FirebaseException platformExceptionToFirebaseFunctionsException(
    PlatformException platformException,
    [StackTrace? stackTrace]) {
  Map<String, dynamic>? details = platformException.details != null
      ? Map<String, dynamic>.from(platformException.details)
      : null;
  dynamic additionalData = details != null ? details['additionalData'] : null;

  String code = 'unknown';
  String? message = platformException.message;

  if (details != null) {
    code = details['code'] ?? code;
    message = details['message'] ?? message;
  }

  return FirebaseFunctionsException(
      code: code, message: message!, details: additionalData);
}
