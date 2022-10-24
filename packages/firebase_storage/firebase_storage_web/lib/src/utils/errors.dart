// ignore_for_file: require_trailing_commas
// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:_flutterfire_internals/_flutterfire_internals.dart'
    as internals;
import 'package:firebase_core/firebase_core.dart';

Map<String, String?> _errorCodeToMessage = {
  'unauthorized': 'User is not authorized to perform the desired action.',
  'object-not-found': 'No object exists at the desired reference.',
  'invalid-argument': null, // let error pass-through
  'canceled': null,
};

/// Will return a [FirebaseException] from a thrown web error.
/// Any other errors will be propagated as normal.
R guard<R>(R Function() cb) {
  return internals.guardWebExceptions(
    cb,
    plugin: 'firebase_storage',
    codeParser: (code) => code.split('/').last,
    messageParser: (code, message) {
      return _errorCodeToMessage[code] ?? message;
    },
  );
}
