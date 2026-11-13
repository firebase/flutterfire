// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Returns the result of [cb].
///
/// The web version, in `firebase_core_js`, maps Firebase JS errors to
/// `FirebaseException`. Off the web there are no JS errors to map.
R guardWebExceptions<R>(
  R Function() cb, {
  required String plugin,
  required String Function(String) codeParser,
  String Function(String code, String message)? messageParser,
}) {
  return cb();
}
