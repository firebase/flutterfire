import 'dart:async';
import 'dart:convert';
import 'dart:js';

import 'package:func/func.dart';
import 'package:js/js.dart';

import 'interop/firebase_interop.dart';
import 'interop/js_interop.dart' as js;

/// Returns Dart representation from JS Object.
dynamic dartify(Object jsObject) {
  if (_isBasicType(jsObject)) {
    return jsObject;
  }

  var json = js.stringify(jsObject);
  return JSON.decode(json);
}

/// Returns the JS implementation from Dart Object.
dynamic jsify(Object dartObject) {
  if (_isBasicType(dartObject)) {
    return dartObject;
  }

  Object json;
  try {
    json = JSON.encode(dartObject, toEncodable: _noCustomEncodable);
  } on JsonUnsupportedObjectError {
    throw new ArgumentError("Only basic JS types are supported");
  }
  return js.parse(json);
}

/// Returns [:true:] if the [value] is a very basic built-in type - e.g.
/// [null], [num], [bool] or [String]. It returns [:false:] in the other case.
bool _isBasicType(value) {
  if (value == null || value is num || value is bool || value is String) {
    return true;
  }
  return false;
}

_noCustomEncodable(value) =>
    throw new UnsupportedError("Object with toJson shouldn't work either");

/// Handles the [thenable] object.
Future/*<T>*/ handleThenable/*<T>*/(ThenableJsImpl thenable) {
  var completer = new Completer/*<T>*/();

  thenable.then(allowInterop(([value]) {
    completer.complete(value);
  }), resolveError(completer));
  return completer.future;
}

/// Handles the [thenable] object with provided [mapper] function.
Future<S> handleThenableWithMapper<T, S>(
    ThenableJsImpl<T> thenable, Func1<T, S> mapper) {
  var completer = new Completer<S>();

  thenable.then(allowInterop((val) {
    var mappedValue = mapper(val);
    completer.complete(mappedValue);
  }), resolveError(completer));
  return completer.future;
}

/// Resolves error.
VoidFunc1 resolveError(Completer c) => allowInterop(c.completeError);
