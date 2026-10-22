// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

import '../../../cloud_functions_platform_interface.dart';

/// Catches a [PlatformException] and returns an [Exception].
///
/// If the [Exception] is a [PlatformException], a [FirebaseFunctionsException] is returned.
Never convertPlatformException(Object exception, StackTrace stackTrace) {
  if (exception is! Exception || exception is! PlatformException) {
    Error.throwWithStackTrace(exception, stackTrace);
  }

  Error.throwWithStackTrace(
    platformExceptionToFirebaseFunctionsException(exception, stackTrace),
    stackTrace,
  );
}

/// Converts a [PlatformException] into a [FirebaseFunctionsException].
///
/// A [PlatformException] can only be converted to a [FirebaseFunctionsException] if
/// the `details` of the exception exist. Firebase returns specific codes and
/// messages which can be converted into user friendly exceptions.
FirebaseException platformExceptionToFirebaseFunctionsException(
  PlatformException platformException,
  StackTrace stackTrace,
) {
  Map<String, dynamic>? details = platformException.details is Map
      ? Map<String, dynamic>.from(platformException.details as Map)
      : null;
  dynamic additionalData = details != null ? details['additionalData'] : null;

  String code = 'unknown';
  String? message = platformException.message;

  if (details != null) {
    final Object? rawCode = details['code'];
    if (rawCode is String) {
      code = rawCode;
    }
    final Object? rawMessage = details['message'];
    if (rawMessage is String) {
      message = rawMessage;
    }
  }

  return FirebaseFunctionsException(
    code: code,
    message: message ?? code,
    details: additionalData,
    stackTrace: stackTrace,
  );
}
