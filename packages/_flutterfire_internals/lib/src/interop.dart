// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:js_interop';

@JS()
@staticInterop
class JSError {}

extension JSErrorExtension on JSError {
  external JSString? get name;
  external JSString? get message;
  external JSString? get code;

  external JSString? get stack;

  // "customData" - see Firebase AuthError docs: https://firebase.google.com/docs/reference/js/auth.autherror
  external JSAny get customData;
}
