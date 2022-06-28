// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_unused_constructor_parameters, non_constant_identifier_names, comment_references
// ignore_for_file: public_member_api_docs

@JS('firebase_app_check')
library firebase_interop.app_check;

import 'package:firebase_core_web/firebase_core_web_interop.dart';
import 'package:js/js.dart';

@JS()
external AppCheckJsImpl initializeAppCheck(
  AppJsImpl? app, [
  AppCheckOptions? options,
]);

@JS()
external PromiseJsImpl<AppCheckTokenResult> getToken(
  AppCheckJsImpl? appCheck,
  bool? forceRefresh,
);

@JS()
external void setTokenAutoRefreshEnabled(
  AppCheckJsImpl appCheck,
  bool isTokenAutoRefreshEnabled,
);

@JS()
class ReCaptchaV3Provider {
  external factory ReCaptchaV3Provider(recaptchaKey);
}

@JS()
abstract class AppCheckTokenResult {
  external String get token;
}

@anonymous
@JS()
class AppCheckOptions {
  external bool? get isTokenAutoRefreshEnabled;
  external ReCaptchaV3Provider get provider;
  external factory AppCheckOptions({
    bool? isTokenAutoRefreshEnabled,
    ReCaptchaV3Provider provider,
  });
}

external Func0 onTokenChanged(
  AppCheckJsImpl appCheck,
  dynamic nextOrObserver, [
  Func1? opt_error,
  Func0? opt_completed,
]);

@JS('AppCheck')
abstract class AppCheckJsImpl {
  external AppJsImpl get app;
}
