// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_web/firebase_core_web_interop.dart'
    as core_interop;

String _parseErrorCode(String errorCode) {
  return errorCode.split('/').last;
}

Map<String, String?> _errorCodeToMessage = {
  'unauthorized': 'User is not authorized to perform the desired action.',
  'object-not-found': 'No object exists at the desired reference.',
  'invalid-argument': null, // let error pass-through
  'canceled': null,
};

String _getErrorMessage(String errorCode, String errorMessage) {
  return _errorCodeToMessage[_parseErrorCode(errorCode)] ?? errorMessage;
}

/// Convert FirebaseErrors from the JS-interop layer into FirebaseExceptions for the plugin.
FirebaseException getFirebaseException(Object object) {
  if (object is! core_interop.FirebaseError) {
    return FirebaseException(
        plugin: 'firebase_storage', message: object.toString());
  }

  core_interop.FirebaseError firebaseError = object;

  return FirebaseException(
    plugin: 'firebase_storage',
    code: _parseErrorCode(firebaseError.code),
    message: _getErrorMessage(firebaseError.code, firebaseError.message),
  );
}
