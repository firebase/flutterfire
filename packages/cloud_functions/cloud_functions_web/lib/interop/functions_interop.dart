// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: avoid_unused_constructor_parameters, non_constant_identifier_names, public_member_api_docs

@JS('firebase_functions')
library firebase_interop.functions;

import 'package:firebase_core_web/firebase_core_web_interop.dart';

import 'package:js/js.dart';

@JS()
external FunctionsJsImpl getFunctions([AppJsImpl? app, String? regionOrDomain]);

@JS()
external void connectFunctionsEmulator(
    FunctionsJsImpl functions, String host, int port);

@JS()
external CustomFunction httpsCallable(FunctionsJsImpl functions, String name,
    [HttpsCallableOptions? options]);

//TODO - implement once web v9 SDK lands
@JS()
external CustomFunction httpsCallableFromURL(
    FunctionsJsImpl functions, String url,
    [HttpsCallableOptions? options]);

/// The Cloud Functions for Firebase service interface.
///
/// Do not call this constructor directly. Instead, use firebase.functions().
/// See: <https://firebase.google.com/docs/reference/js/firebase.functions.Functions>.
@JS('Functions')
abstract class FunctionsJsImpl {
  external AppJsImpl get app;
  external String? get customDomain;
  external String get region;
}

/// An HttpsCallableOptions is an option to set timeout property
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.functions.HttpsCallableOptions>.
@JS('HttpsCallableOptions')
@anonymous
abstract class HttpsCallableOptions {
  external factory HttpsCallableOptions({int? timeout});
  external int get timeout;
  external set timeout(int t);
}

/// An HttpsCallableResult wraps a single result from a function call.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.functions.HttpsCallableResult>.
@JS('HttpsCallableResult')
@anonymous
abstract class HttpsCallableResultJsImpl {
  external Map<String, dynamic> get data;
}

/// The set of Cloud Functions status codes.
/// These status codes are also exposed by gRPC.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.functions.HttpsError>.
@JS('HttpsError')
abstract class HttpsErrorJsImpl {
  external ErrorJsImpl get error;
  external set error(ErrorJsImpl e);
  external String get code;
  external set code(String v);
  external dynamic get details;
  external set details(dynamic d);
  external String get message;
  external set message(String v);
  external String get name;
  external set name(String v);
  external String get stack;
  external set stack(String s);
}

@JS('Error')
abstract class ErrorJsImpl {
  external String get message;
  external set message(String m);
  external String get fileName;
  external set fileName(String f);
  external String get lineNumber;
  external set lineNumber(String l);
}

@JS('Function')
class CustomFunction {
  external PromiseJsImpl<dynamic> apply(dynamic thisArg, List<dynamic> args);
}
