// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: require_trailing_commas
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

import 'package:_flutterfire_internals/_flutterfire_internals.dart';

import 'error_code.dart';

/// Catches a [PlatformException] and returns an [Exception].
///
/// If the [Exception] is a [PlatformException], a [FirebaseException] is returned.
///
/// The native SDKs report anything that is not throttling or a server error as
/// `internal` or `unknown`, so the code is refined from the native message
/// where possible, see [refineRemoteConfigErrorCode].
Never convertPlatformException(Object exception, StackTrace stackTrace) {
  if (exception is PlatformException) {
    final FirebaseException firebaseException =
        platformExceptionToFirebaseException(
      exception,
      plugin: 'firebase_remote_config',
    );

    final String code = refineRemoteConfigErrorCode(
      firebaseException.code,
      firebaseException.message,
    );

    if (code != firebaseException.code) {
      Error.throwWithStackTrace(
        FirebaseException(
          plugin: firebaseException.plugin,
          code: code,
          message: firebaseException.message,
          stackTrace: firebaseException.stackTrace,
        ),
        stackTrace == StackTrace.empty ? StackTrace.current : stackTrace,
      );
    }
  }

  convertPlatformExceptionToFirebaseException(
    exception,
    stackTrace,
    plugin: 'firebase_remote_config',
  );
}
