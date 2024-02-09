// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

@JS()
library firebase_interop.core.es6;

import 'dart:js_interop' as js_interop;

import 'package:js/js.dart';

import 'func.dart';

@JS('Promise')
class PromiseJsImpl<T> {
  external PromiseJsImpl(Function resolver);
  external PromiseJsImpl then([Func1? onResolve, Func1? onReject]);
}

@js_interop.JS()
@js_interop.staticInterop
class JSError {}

extension JSErrorExtension on JSError {
  external js_interop.JSString? get name;
  external js_interop.JSString? get message;
  external js_interop.JSString? get code;

  external js_interop.JSString? get stack;

  // "customData" - see Firebase AuthError docs: https://firebase.google.com/docs/reference/js/auth.autherror
  external js_interop.JSAny get customData;
}
