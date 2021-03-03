// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_web/firebase_core_web_interop.dart'
    as core_interop;

/// Returns a [FirebaseException] from a thrown web error.
FirebaseException getFirebaseException(Object object) {
  if (object is! core_interop.FirebaseError) {
    return FirebaseException(
        plugin: 'cloud_firestore', message: object.toString());
  }

  core_interop.FirebaseError firebaseError = object;

  String code = firebaseError.code.replaceFirst('firestore/', '');
  String message =
      firebaseError.message.replaceFirst('(${firebaseError.code})', '');
  return FirebaseException(
      plugin: 'cloud_firestore', code: code, message: message);
}
