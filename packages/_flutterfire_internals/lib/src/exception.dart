// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

/// Catches a [PlatformException] and returns an [Exception].
///
/// If the [Exception] is a [PlatformException], a [FirebaseException] is returned.
Never convertPlatformExceptionToFirebaseException(
  Object exception,
  StackTrace rawStackTrace, {
  required String plugin,
}) {
  var stackTrace = rawStackTrace;
  if (stackTrace == StackTrace.empty) {
    stackTrace = StackTrace.current;
  }

  if (exception is! PlatformException) {
    Error.throwWithStackTrace(exception, stackTrace);
  }

  Error.throwWithStackTrace(
    platformExceptionToFirebaseException(exception, plugin: plugin),
    stackTrace,
  );
}

/// Converts a [PlatformException] into a [FirebaseException].
///
/// Firebase returns specific codes and messages which can be converted into
/// user friendly exceptions. Most native implementations carry them in the
/// `details` of the exception, but a code sent as [PlatformException.code] is
/// honoured as well: the Windows plugins report native Firebase codes that way,
/// with no `details` payload at all.
FirebaseException platformExceptionToFirebaseException(
  PlatformException platformException, {
  required String plugin,
}) {
  Map<String, Object>? details;

  final rawDetails = platformException.details;

  if (rawDetails is Map) {
    details = Map<String, Object>.from(rawDetails);
  }

  String? code;
  String message = platformException.message ?? '';

  if (details != null) {
    code = details['code'] as String?;
    message = details['message'] as String? ?? message;
  } else if (rawDetails != null) {
    message = rawDetails.toString();
  } else if (platformException.code.isNotEmpty &&
      platformException.code != plugin) {
    // With no `details` payload at all, honour a code sent in the standard
    // `PlatformException.code` field: the Windows plugins report native
    // Firebase codes that way, because the Pigeon C++
    // `FlutterError(code, message)` and `EventSink::Error(code, message)`
    // overloads both send null details. Without this the code is lost and every
    // such error surfaces as `unknown`.
    //
    // Normalised to the casing Firebase codes use, as
    // `platformExceptionToFirebaseAuthException` already does for the same
    // field, so that a native `UNKNOWN` or `PERMISSION_DENIED` does not leak
    // through in a shape no caller can compare against.
    //
    // The plugin name itself is not a code - the Android and Windows Pigeon
    // APIs send it in that field as a channel-level marker and carry the real
    // code in `details` - so it is treated as absent rather than reported as
    // `FirebaseException(code: 'firebase_database')`.
    code = platformException.code.toLowerCase().replaceAll('_', '-');
  }

  return FirebaseException(
    plugin: plugin,
    code: code ?? 'unknown',
    message: message,
  );
}

/// A custom [EventChannel] with default error handling logic.
extension EventChannelExtension on EventChannel {
  /// Similar to [receiveBroadcastStream], but with enforced error handling.
  Stream<dynamic> receiveGuardedBroadcastStream({
    dynamic arguments,
    required dynamic Function(Object error, StackTrace stackTrace) onError,
  }) {
    final incomingStackTrace = StackTrace.current;

    return receiveBroadcastStream(arguments).handleError((Object error) {
      // TODO(rrousselGit): use package:stack_trace to merge the error's StackTrace with "incomingStackTrace"
      // This TODO assumes that EventChannel is updated to actually pass a StackTrace
      // (as it currently only sends StackTrace.empty)
      return onError(error, incomingStackTrace);
    });
  }
}
