// ignore_for_file: avoid_unused_constructor_parameters, non_constant_identifier_names

@JS('firebase.functions')
library firebase.functions_interop;

import 'package:js/js.dart';
import 'es6_interop.dart';

/// The Cloud Functions for Firebase service interface.
///
/// Do not call this constructor directly. Instead, use firebase.functions().
/// See: <https://firebase.google.com/docs/reference/js/firebase.functions.Functions>.
@JS('Functions')
abstract class FunctionsJsImpl {
  external FunctionsJsImpl get functions;
  external HttpsCallableJsImpl httpsCallable(String name,
      [HttpsCallableOptions options]);
  external void useFunctionsEmulator(String url);
}

/// An HttpsCallable is a reference to a 'callable' http trigger
/// in Google Cloud Functions.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.functions.Functions>.
@JS('HttpsCallable')
abstract class HttpsCallableJsImpl {
  external PromiseJsImpl<HttpsCallableResultJsImpl> call(dynamic data);
}

/// An HttpsCallableOptions is an option to set timeout property
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.functions.HttpsCallableOptions>.
@JS('HttpsCallableOptions')
@anonymous
abstract class HttpsCallableOptions {
  external int get timeout;
  external set timeout(int t);

  external factory HttpsCallableOptions({int timeout});
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
  external dynamic /*|'ok'|'cancelled'|'unknown'|'invalid-argument'|'deadline-exceeded'|'not-found'|'already-exists'|'permission-denied'|'resource-exhausted'|'failed-precondition'|'aborted'|'out-of-range'|'unimplemented'|'internal'|'unavailable'|'data-loss'|'unauthenticated'*/ get code;
  external set code(
      /*|'ok'|'cancelled'|'unknown'|'invalid-argument'|'deadline-exceeded'|'not-found'|'already-exists'|'permission-denied'|'resource-exhausted'|'failed-precondition'|'aborted'|'out-of-range'|'unimplemented'|'internal'|'unavailable'|'data-loss'|'unauthenticated'*/ v);
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
