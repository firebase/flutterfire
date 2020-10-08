import 'dart:async';

import 'package:js/js.dart';
import 'package:js/js_util.dart' as util;

import 'func.dart';
import 'es6_interop.dart';
import 'js_interop.dart' as js;
import '../core.dart' show FirebaseError;

/// Returns Dart representation from JS Object.
dynamic dartify(Object jsObject) {
  if (_isBasicType(jsObject)) {
    return jsObject;
  }

  // Handle list
  if (jsObject is Iterable) {
    return jsObject.map(dartify).toList();
  }

  var jsDate = js.dartifyDate(jsObject);
  if (jsDate != null) {
    return jsDate;
  }

  // Assume a map then...
  return dartifyMap(jsObject);
}

Map<String, dynamic> dartifyMap(Object jsObject) {
  var keys = js.objectKeys(jsObject);
  var map = <String, dynamic>{};
  for (var key in keys) {
    map[key] = dartify(util.getProperty(jsObject, key));
  }
  return map;
}

dynamic jsifyList(Iterable list) {
  return js.toJSArray(list.map(jsify).toList());
}

// Returns the JS implementation from Dart Object.
dynamic jsify(Object dartObject) {
  if (_isBasicType(dartObject)) {
    return dartObject;
  }

  if (dartObject is Iterable) {
    return jsifyList(dartObject);
  }

  if (dartObject is Map) {
    var jsMap = util.newObject();
    dartObject.forEach((key, value) {
      util.setProperty(jsMap, key, jsify(value));
    });
    return jsMap;
  }

  if (dartObject is Function) {
    return allowInterop(dartObject);
  }

  throw ArgumentError.value(dartObject, 'dartObject', 'Could not convert');
}

/// Calls [method] on JavaScript object [jsObject].
dynamic callMethod(Object jsObject, String method, List<dynamic> args) =>
    util.callMethod(jsObject, method, args);

/// Returns `true` if the [value] is a very basic built-in type - e.g.
/// `null`, [num], [bool] or [String]. It returns `false` in the other case.
bool _isBasicType(Object value) {
  if (value == null || value is num || value is bool || value is String) {
    return true;
  }
  return false;
}

/// Handles the [PromiseJsImpl] object.
Future<T> handleThenable<T>(PromiseJsImpl<T> thenable) async {
  T value;
  try {
    value = await util.promiseToFuture(thenable);
  } catch (e) {
    if (util.hasProperty(e, 'code')) {
      //TODO throw _FirebaseErrorWrapper(e);
    }
    rethrow;
  }
  return value;
}

/// Handles the [Future] object with the provided [mapper] function.
PromiseJsImpl<S> handleFutureWithMapper<T, S>(
    Future<T> future, Func1<T, S> mapper) {
  return PromiseJsImpl<S>(allowInterop((
    void Function(S) resolve,
    void Function(Object) reject,
  ) {
    future.then((value) {
      var mappedValue = mapper(value);
      resolve(mappedValue);
    }).catchError(reject);
  }));
}

/// Resolves error.
// void Function(Object) resolveError(Completer c) =>
//     allowInterop(c.completeError);

class _FirebaseErrorWrapper extends Error implements FirebaseError {
  final FirebaseError _source;

  _FirebaseErrorWrapper(this._source);

  @override
  String get code => util.getProperty(_source, 'code');

  @override
  String get message => util.getProperty(_source, 'message');

  @override
  String get name => util.getProperty(_source, 'name');

  @override
  Object get serverResponse => util.getProperty(_source, 'serverResponse');

  @override
  String get stack => util.getProperty(_source, 'stack');

  @override
  String toString() => 'FirebaseError: $message ($code)';
}
