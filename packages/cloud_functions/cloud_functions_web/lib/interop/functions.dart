// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'package:firebase_core_web/firebase_core_web_interop.dart';

import 'functions_interop.dart' as functions_interop;

export 'functions_interop.dart' show HttpsCallableOptions;

/// Given an AppJSImp, return the Functions instance.
Functions getFunctionsInstance(App app, [String? region]) {
  functions_interop.FunctionsJsImpl jsObject;
  if (region == null) {
    jsObject = functions_interop.getFunctions(app.jsObject);
  } else {
    jsObject = functions_interop.getFunctions(app.jsObject, region);
  }
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
    functions_interop.CustomFunction httpCallableImpl;
    if (options != null) {
      httpCallableImpl =
          functions_interop.httpsCallable(jsObject, name, options);
    } else {
      httpCallableImpl = functions_interop.httpsCallable(jsObject, name);
    }
    return HttpsCallable.getInstance(httpCallableImpl);
  }

  void useFunctionsEmulator(String host, int port) =>
      functions_interop.connectFunctionsEmulator(jsObject, host, port);
}

class HttpsCallable extends JsObjectWrapper<functions_interop.CustomFunction> {
  HttpsCallable._fromJsObject(functions_interop.CustomFunction jsObject)
      : super.fromJsObject(jsObject);

  static final _expando = Expando<HttpsCallable>();

  /// Creates a new HttpsCallable from a [jsObject].
  static HttpsCallable getInstance(functions_interop.CustomFunction jsObject) {
    return _expando[jsObject] ??= HttpsCallable._fromJsObject(jsObject);
  }

  Future<HttpsCallableResult> call([dynamic data]) =>
      handleThenable(jsObject.apply(null, [data])).then((result) {
        return HttpsCallableResult.getInstance(
            result as functions_interop.HttpsCallableResultJsImpl);
      });
}

class HttpsCallableResult
    extends JsObjectWrapper<functions_interop.HttpsCallableResultJsImpl> {
  HttpsCallableResult._fromJsObject(
      functions_interop.HttpsCallableResultJsImpl jsObject)
      : _data = dartify(jsObject.data),
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
