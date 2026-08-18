// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: avoid_unused_constructor_parameters, non_constant_identifier_names, public_member_api_docs

@JS('firebase_analytics')
library;

import 'dart:js_interop';

import 'package:firebase_core_web/firebase_core_web_interop.dart';

@JS()
@staticInterop
external AnalyticsJsImpl getAnalytics([AppJsImpl? app]);

@JS()
@staticInterop
external AnalyticsJsImpl initializeAnalytics(
  AppJsImpl app, [
  JSAny? options,
]);

@JS()
@staticInterop
external JSPromise<JSBoolean> isSupported();

@JS()
@staticInterop
external void logEvent(
  AnalyticsJsImpl analytics,
  JSString eventName,
  JSAny? parameters,
  JSObject? callOptions,
);

@JS()
@staticInterop
external void setConsent(
  // https://firebase.google.com/docs/reference/js/analytics.consentsettings.md#consentsettings_interface
  JSAny? consentSettings,
);

@JS()
@staticInterop
external void setAnalyticsCollectionEnabled(
  AnalyticsJsImpl analytics,
  JSBoolean enabled,
);

@JS()
@staticInterop
external void setUserId(
  AnalyticsJsImpl analytics,
  JSString? id,
  JSObject? callOptions,
);

@JS()
@staticInterop
external void setUserProperties(
  AnalyticsJsImpl analytics,
  JSAny? property,
  JSObject? callOptions,
);

extension type AnalyticsJsImpl._(JSObject _) implements JSObject {
  external AppJsImpl get app;
}
