// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

/// Catches a [PlatformException] and converts it into a [FirebaseException] if
/// it was intentially caught on the native platform.
FutureOr<Map<String, dynamic>> catchPlatformException(Object exception) async {
  if (exception is! Exception || exception is! PlatformException) {
    throw exception;
  }

  throw platformExceptionToFirebaseException(exception as PlatformException);
}

/// Converts a [PlatformException] into a [FirebaseException].
///
/// A [PlatformException] can only be converted to a [FirebaseException] if the
/// `details` of the exception exist. Firebase returns specific codes and messages
/// which can be converted into user friendly exceptions.
FirebaseException platformExceptionToFirebaseException(
    PlatformException platformException) {
  Map<String, String> details = platformException.details != null
      ? Map<String, String>.from(platformException.details)
      : null;

  String code = 'unknown';
  String message = platformException.message;

  if (details != null) {
    code = details['code'] ?? code;
    message = details['message'] ?? message;
  }

  return FirebaseException(
      plugin: 'cloud_firestore', code: code, message: message);
}
