// ignore_for_file: public_member_api_docs, avoid_unused_constructor_parameters, non_constant_identifier_names, comment_references
// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@JS('firebase.app')
library firebase_interop.core.app;

import 'dart:async';

import 'package:firebase_core_web/firebase_core_web_interop.dart'
    as core_interop;
import 'package:js/js.dart';
import 'package:js/js_util.dart' as util;

/// Returns Dart representation from JS Object.
///
/// The optional [customDartify] function may return `null` to indicate,
/// that it could not handle the given JS Object.
dynamic dartify(
  Object? jsObject, [
  Object? Function(Object? object)? customDartify,
]) {
  if (_isBasicType(jsObject)) {
    return jsObject;
  }

  // Handle list
  if (jsObject is Iterable) {
    return jsObject.map((item) => dartify(item, customDartify)).toList();
  }

  var jsDate = core_interop.dartifyDate(jsObject!);
  if (jsDate != null) {
    return jsDate;
  }

  Object? value = customDartify?.call(jsObject);

  if (value == null) {
    var keys = core_interop.objectKeys(jsObject);
    var map = <String, dynamic>{};
    for (final key in keys) {
      map[key] = dartify(util.getProperty(jsObject, key), customDartify);
    }
    return map;
  }

  return value;
}

// Converts an Iterable into a JS Array
dynamic jsifyList(
  Iterable list, [
  Object? Function(Object? object)? customJsify,
]) {
  return core_interop
      .toJSArray(list.map((item) => jsify(item, customJsify)).toList());
}

/// Returns the JS implementation from Dart Object.
///
/// The optional [customJsify] function may return `null` to indicate,
/// that it could not handle the given Dart Object.
dynamic jsify(
  Object? dartObject, [
  Object? Function(Object? object)? customJsify,
]) {
  if (_isBasicType(dartObject)) {
    return dartObject;
  }

  if (dartObject is Iterable) {
    return jsifyList(dartObject, customJsify);
  }

  if (dartObject is Map) {
    var jsMap = util.newObject();
    dartObject.forEach((key, value) {
      util.setProperty(jsMap, key, jsify(value, customJsify));
    });
    return jsMap;
  }

  if (dartObject is Function) {
    return allowInterop(dartObject);
  }

  Object? value = customJsify?.call(dartObject);

  if (value == null) {
    throw ArgumentError.value(dartObject, 'dartObject', 'Could not convert');
  }

  return value;
}

/// Calls [method] on JavaScript object [jsObject].
dynamic callMethod(Object jsObject, String method, List<dynamic> args) =>
    util.callMethod(jsObject, method, args);

/// Returns `true` if the [value] is a very basic built-in type - e.g.
/// `null`, [num], [bool] or [String]. It returns `false` in the other case.
bool _isBasicType(Object? value) {
  if (value == null || value is num || value is bool || value is String) {
    return true;
  }
  return false;
}

/// Resolves error.
void Function(Object) resolveError(Completer c) =>
    allowInterop(c.completeError);

@JS('undefined')
external Object undefined;
