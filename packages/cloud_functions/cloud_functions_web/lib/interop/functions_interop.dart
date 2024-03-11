// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: avoid_unused_constructor_parameters, non_constant_identifier_names, public_member_api_docs

@JS('firebase_functions')
library firebase_interop.functions;

import 'dart:js_interop';

import 'package:firebase_core_web/firebase_core_web_interop.dart';

@JS()
@staticInterop
external FunctionsJsImpl getFunctions(
    [AppJsImpl? app, JSString? regionOrDomain]);

@JS()
@staticInterop
external void connectFunctionsEmulator(
    FunctionsJsImpl functions, JSString host, JSNumber port);

@JS()
@staticInterop
external JSFunction httpsCallable(FunctionsJsImpl functions, JSString name,
    [HttpsCallableOptions? options]);

@JS()
@staticInterop
external JSFunction httpsCallableFromURL(
    FunctionsJsImpl functions, JSString url,
    [HttpsCallableOptions? options]);

/// The Cloud Functions for Firebase service interface.
///
/// Do not call this constructor directly. Instead, use firebase.functions().
/// See: <https://firebase.google.com/docs/reference/js/firebase.functions.Functions>.
@JS('Functions')
@staticInterop
abstract class FunctionsJsImpl {}

extension FunctionsJsImplExtension on FunctionsJsImpl {
  external AppJsImpl get app;
  external JSString? get customDomain;
  external JSString get region;
}

/// An HttpsCallableOptions is an option to set timeout property
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.functions.HttpsCallableOptions>.
@JS('HttpsCallableOptions')
@staticInterop
@anonymous
abstract class HttpsCallableOptions {
  external factory HttpsCallableOptions(
      {JSNumber? timeout, JSBoolean? limitedUseAppCheckTokens});
}

extension HttpsCallableOptionsExtension on HttpsCallableOptions {
  external JSNumber? get timeout;
  external set timeout(JSNumber? t);
  external JSBoolean? get limitedUseAppCheckTokens;
  external set limitedUseAppCheckTokens(JSBoolean? t);
}

/// An HttpsCallableResult wraps a single result from a function call.
///
/// See: <https://firebase.google.com/docs/reference/js/functions.httpscallableresult>.
@JS('HttpsCallableResult')
@staticInterop
@anonymous
abstract class HttpsCallableResultJsImpl {}

extension HttpsCallableResultJsImplExtension on HttpsCallableResultJsImpl {
  external JSAny? get data;
}
