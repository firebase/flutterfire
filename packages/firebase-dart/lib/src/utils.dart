import 'dart:async';
import 'dart:convert';

import 'package:func/func.dart';
import 'package:js/js.dart';
import 'package:js/js_util.dart' as util;

import 'interop/firebase_interop.dart';
import 'interop/js_interop.dart' as js;

/// Returns Dart representation from JS Object.
dynamic dartify(Object jsObject) {
  if (_isBasicType(jsObject)) {
    return jsObject;
  }

  if (jsObject is List) {
    return jsObject.map(dartify).toList();
  }

  var json = js.stringify(jsObject);
  return JSON.decode(json);
}

/// Returns the JS implementation from Dart Object.
dynamic jsify(Object dartObject) {
  if (_isBasicType(dartObject)) {
    return dartObject;
  }

  return util.jsify(dartObject);
}

/// Calls [method] on JavaScript object [jsObject].
dynamic callMethod(Object jsObject, String method, List<dynamic> args) =>
    util.callMethod(jsObject, method, args);

/// Returns [:true:] if the [value] is a very basic built-in type - e.g.
/// [null], [num], [bool] or [String]. It returns [:false:] in the other case.
bool _isBasicType(value) {
  if (value == null || value is num || value is bool || value is String) {
    return true;
  }
  return false;
}

/// Handles the [Thenable] object.
Future<T> handleThenable<T>(ThenableJsImpl<T> thenable) {
  var completer = new Completer<T>();

  thenable.then(allowInterop(([value]) {
    completer.complete(value);
  }), resolveError(completer));
  return completer.future;
}

/// Handles the [Thenable] object with the provided [mapper] function.
Future<S> handleThenableWithMapper<T, S>(
    ThenableJsImpl<T> thenable, Func1<T, S> mapper) {
  var completer = new Completer<S>();

  thenable.then(allowInterop((val) {
    var mappedValue = mapper(val);
    completer.complete(mappedValue);
  }), resolveError(completer));
  return completer.future;
}

/// Handles the [Future] object with the provided [mapper] function.
PromiseJsImpl<S> handleFutureWithMapper<T, S>(
    Future<T> future, Func1<T, S> mapper) {
  return new PromiseJsImpl<S>(
      allowInterop((VoidFunc1 resolve, VoidFunc1 reject) {
    future.then((value) {
      var mappedValue = mapper(value);
      resolve(mappedValue);
    }).catchError((error) {
      reject(error);
    });
  }));
}

/// Resolves error.
VoidFunc1 resolveError(Completer c) => allowInterop(c.completeError);
