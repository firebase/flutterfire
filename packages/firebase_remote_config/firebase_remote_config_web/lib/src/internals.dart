// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:_flutterfire_internals/_flutterfire_internals.dart'
    as internals;

/// The codes the JS SDK reports realtime update errors with, mapped to the
/// codes Android and iOS report the same errors with.
const Map<String, String> _configUpdateErrorCodes = <String, String>{
  'remoteconfig/stream-error': 'config-update-stream-error',
  'remoteconfig/update-message-invalid': 'config-update-message-invalid',
  'remoteconfig/update-not-fetched': 'config-update-not-fetched',
  'remoteconfig/realtime-unavailable': 'config-update-unavailable',
};

/// Will return a [FirebaseException] from a thrown web error.
/// Any other errors will be propagated as normal.
R convertWebExceptions<R>(R Function() cb) {
  return internals.guardWebExceptions(
    cb,
    plugin: 'firebase_remote_config',
    codeParser: (code) =>
        _configUpdateErrorCodes[code] ??
        code.replaceFirst('remote_config/', ''),
  );
}
