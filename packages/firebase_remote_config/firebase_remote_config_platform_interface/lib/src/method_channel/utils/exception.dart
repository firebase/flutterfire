// @dart=2.9

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

/// Catches a [PlatformException] and converts it into a [FirebaseException] if
/// it was intentionally caught on the native platform.
Exception convertPlatformException(Object exception, [StackTrace stackTrace]) {
  if (exception is! Exception || exception is! PlatformException) {
    // ignore: only_throw_errors
    throw exception;
  }

  return platformExceptionToFirebaseException(
    exception as PlatformException,
    stackTrace,
  );
}

/// Converts a [PlatformException] into a [FirebaseException].
///
/// A [PlatformException] can only be converted to a [FirebaseException] if the
/// `details` of the exception exist. Firebase returns specific codes and messages
/// which can be converted into user friendly exceptions.
FirebaseException platformExceptionToFirebaseException(
    PlatformException platformException,
    [StackTrace stackTrace]) {
  Map<String, String> details = platformException.details != null
      ? Map<String, dynamic>.from(platformException.details)
      : null;

  String code = 'unknown';
  String message = platformException.message;

  if (details != null) {
    code = details['code'] ?? code;
    message = details['message'] ?? message;
  }

  return FirebaseException(
    plugin: 'firebase_remote_config',
    code: code,
    message: message,
    stackTrace: stackTrace,
  );
}
