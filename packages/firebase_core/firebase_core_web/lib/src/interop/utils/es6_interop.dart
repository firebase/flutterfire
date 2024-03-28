// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

@JS()
library firebase_interop.core.es6;

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
