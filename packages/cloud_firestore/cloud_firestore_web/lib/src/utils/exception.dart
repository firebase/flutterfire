// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';

import 'package:firebase/firebase.dart' as firebase;

/// Given a web error, an [Exception] is returned.
///
/// The firebase-dart wrapper exposes a [firebase.FirebaseError], allowing us to
/// use the code and message and convert it into an expected.
Exception convertPlatformException(Object exception) {
  if (exception is! firebase.FirebaseError) {
    return exception;
  }

  firebase.FirebaseError firebaseError = exception as firebase.FirebaseError;

  String code = firebaseError.code.replaceFirst('firestore/', '');
  String message =
      firebaseError.message.replaceFirst('(${firebaseError.code})', '');
  return FirebaseException(
      plugin: 'cloud_firestore', code: code, message: message);
}
