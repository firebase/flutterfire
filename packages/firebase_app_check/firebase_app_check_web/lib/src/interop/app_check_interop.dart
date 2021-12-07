// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_unused_constructor_parameters, non_constant_identifier_names, comment_references
// ignore_for_file: public_member_api_docs

@JS('firebase.appCheck')
library firebase_interop.app_check;

import 'package:firebase_core_web/firebase_core_web_interop.dart';
import 'package:js/js.dart';

@JS('AppCheck')
abstract class AppCheckJsImpl {
  external void activate(String? recaptchaKey);

  external void setTokenAutoRefreshEnabled(bool isTokenAutoRefreshEnabled);

  external PromiseJsImpl<AppCheckTokenResult> getToken(bool? forceRefresh);

  external Func0 onTokenChanged(
    dynamic nextOrObserver, [
    Func1? opt_error,
    Func0? opt_completed,
  ]);
}

@JS()
abstract class AppCheckTokenResult {
  external String get token;
}
