// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:js_interop';
import 'package:firebase_core_web/firebase_core_web_interop.dart';

import 'functions_interop.dart' as functions_interop;

export 'functions_interop.dart' show HttpsCallableOptions;

/// Given an AppJSImp, return the Functions instance.
Functions getFunctionsInstance(App app, [String? region]) {
  functions_interop.FunctionsJsImpl jsObject = functions_interop.getFunctions(
    app.jsObject,
    region?.toJS,
  );
  return Functions.getInstance(jsObject);
}

class Functions extends JsObjectWrapper<functions_interop.FunctionsJsImpl> {
  Functions._fromJsObject(functions_interop.FunctionsJsImpl jsObject)
      : super.fromJsObject(jsObject);
  static final _expando = Expando<Functions>();

  /// Creates a new Functions from a [jsObject].
  static Functions getInstance(functions_interop.FunctionsJsImpl jsObject) {
    return _expando[jsObject] ??= Functions._fromJsObject(jsObject);
  }

  Functions get functions => getInstance(jsObject);

  AppJsImpl get app => jsObject.app;

  HttpsCallable httpsCallable(String name,
      [functions_interop.HttpsCallableOptions? options]) {
    JSFunction httpCallableImpl;
    if (options != null) {
      httpCallableImpl =
          functions_interop.httpsCallable(jsObject, name.toJS, options);
    } else {
      httpCallableImpl = functions_interop.httpsCallable(jsObject, name.toJS);
    }
    return HttpsCallable.getInstance(httpCallableImpl);
  }

  HttpsCallable httpsCallableUri(Uri uri,
      [functions_interop.HttpsCallableOptions? options]) {
    JSFunction httpCallableImpl;
    if (options != null) {
      httpCallableImpl = functions_interop.httpsCallableFromURL(
          jsObject, uri.toString().toJS, options);
    } else {
      httpCallableImpl =
          functions_interop.httpsCallableFromURL(jsObject, uri.toString().toJS);
    }
    return HttpsCallable.getInstance(httpCallableImpl);
  }

  void useFunctionsEmulator(String host, int port) => functions_interop
      .connectFunctionsEmulator(jsObject, host.toJS, port.toJS);
}

class HttpsCallable extends JsObjectWrapper<JSFunction> {
  HttpsCallable._fromJsObject(JSFunction jsObject)
      : super.fromJsObject(jsObject);

  static final _expando = Expando<HttpsCallable>();

  /// Creates a new HttpsCallable from a [jsObject].
  static HttpsCallable getInstance(JSFunction jsObject) {
    return _expando[jsObject] ??= HttpsCallable._fromJsObject(jsObject);
  }

  Future<HttpsCallableResult> call(JSAny? data) async {
    final result =
        await (jsObject.callAsFunction(null, data)! as JSPromise).toDart;

    return HttpsCallableResult.getInstance(
      result! as functions_interop.HttpsCallableResultJsImpl,
    );
  }

  Stream<dynamic> stream(JSAny? data,
      functions_interop.HttpsCallableStreamOptions? options) async* {
    final streamCallable = await (jsObject as functions_interop.HttpsCallable)
        .stream(data, options)
        .toDart;
    final streamResult =
        streamCallable! as functions_interop.HttpsCallableStreamResultJsImpl;

    await for (final value in streamResult.stream.asStream()) {
      // ignore: invalid_runtime_check_with_js_interop_types
      final message = value is JSObject
          ? HttpsCallableStreamResult.getInstance(
              value as functions_interop.HttpsStreamIterableResult,
            ).data
          : value;
      yield {'message': message};
    }

    final result = await streamResult.data.toDart;
    yield {'result': result};
  }
}

/// Returns Dart representation from JS Object.
dynamic _dartify(dynamic object) {
  // Convert JSObject to Dart equivalents directly
  // Cannot be done with Dart 3.2 constraints
  // ignore: invalid_runtime_check_with_js_interop_types
  if (object is! JSObject) {
    return object;
  }

  final jsObject = object;

  // Convert nested structures
  final dartObject = jsObject.dartify();
  return _convertNested(dartObject);
}

dynamic _convertNested(dynamic object) {
  if (object is List) {
    return object.map(_convertNested).toList();
  } else if (object is Map) {
    var map = <String, dynamic>{};
    object.forEach((key, value) {
      map[key] = _convertNested(value);
    });
    return map;
  } else {
    // For non-nested types, attempt to convert directly
    return _dartify(object);
  }
}

class HttpsCallableResult
    extends JsObjectWrapper<functions_interop.HttpsCallableResultJsImpl> {
  HttpsCallableResult._fromJsObject(
      functions_interop.HttpsCallableResultJsImpl jsObject)
      : _data = _dartify(jsObject.data),
        super.fromJsObject(jsObject);

  static final _expando = Expando<HttpsCallableResult>();
  final dynamic _data;

  /// Creates a new HttpsCallableResult from a [jsObject].
  static HttpsCallableResult getInstance(
      functions_interop.HttpsCallableResultJsImpl jsObject) {
    return _expando[jsObject] ??= HttpsCallableResult._fromJsObject(jsObject);
  }

  dynamic get data {
    return _data;
  }
}

class HttpsCallableStreamResult
    extends JsObjectWrapper<functions_interop.HttpsStreamIterableResult> {
  HttpsCallableStreamResult._fromJsObject(
      functions_interop.HttpsStreamIterableResult jsObject)
      : _data = _dartify(jsObject.value),
        super.fromJsObject(jsObject);

  static final _expando = Expando<HttpsCallableStreamResult>();
  final dynamic _data;

  /// Creates a new HttpsCallableResult from a [jsObject].
  static HttpsCallableStreamResult getInstance(
      functions_interop.HttpsStreamIterableResult jsObject) {
    return _expando[jsObject] ??=
        HttpsCallableStreamResult._fromJsObject(jsObject);
  }

  dynamic get data {
    return _data;
  }
}
