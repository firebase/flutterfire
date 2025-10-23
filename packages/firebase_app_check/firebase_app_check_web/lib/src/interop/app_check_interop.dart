// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_unused_constructor_parameters, non_constant_identifier_names, comment_references
// ignore_for_file: public_member_api_docs

@JS('firebase_app_check')
library;

import 'dart:js_interop';

import 'package:firebase_core_web/firebase_core_web_interop.dart';

@JS()
@staticInterop
external AppCheckJsImpl initializeAppCheck(
  AppJsImpl? app, [
  AppCheckOptions? options,
]);

@JS()
@staticInterop
external JSPromise<AppCheckTokenResultJsImpl> getToken(
  AppCheckJsImpl? appCheck,
  JSBoolean? forceRefresh,
);

@JS()
@staticInterop
external JSPromise<AppCheckTokenResultJsImpl> getLimitedUseToken(
  AppCheckJsImpl? appCheck,
);

@JS()
@staticInterop
external JSFunction onTokenChanged(
  AppCheckJsImpl appCheck,
  JSAny nextOrObserver, [
  JSFunction? opt_error,
  JSFunction? opt_completed,
]);

@JS()
@staticInterop
external void setTokenAutoRefreshEnabled(
  AppCheckJsImpl appCheck,
  JSBoolean isTokenAutoRefreshEnabled,
);

@JS()
@staticInterop
abstract class ReCaptchaProvider {}

@JS()
@staticInterop
class ReCaptchaV3Provider implements ReCaptchaProvider {
  external factory ReCaptchaV3Provider(JSString recaptchaKey);
}

@JS()
@staticInterop
class ReCaptchaEnterpriseProvider implements ReCaptchaProvider {
  external factory ReCaptchaEnterpriseProvider(JSString recaptchaKey);
}

extension type AppCheckTokenResultJsImpl._(JSObject _) implements JSObject {
  external JSString get token;
}

@anonymous
@JS()
@staticInterop
class AppCheckOptions {
  external factory AppCheckOptions({
    JSBoolean? isTokenAutoRefreshEnabled,
    ReCaptchaProvider provider,
  });
}

extension AppCheckOptionsJsImplX on AppCheckOptions {
  external JSBoolean? get isTokenAutoRefreshEnabled;

  external ReCaptchaProvider get provider;
}

extension type AppCheckJsImpl._(JSObject _) implements JSObject {
  external AppJsImpl get app;
}
