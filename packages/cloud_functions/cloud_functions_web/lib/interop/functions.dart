// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'package:firebase_core_web/firebase_core_web_interop.dart';
import 'functions_interop.dart' as functions_interop;
import 'firebase_interop.dart' as firebase_interop;

export 'functions_interop.dart' show HttpsCallableOptions;

class Functions extends JsObjectWrapper<functions_interop.FunctionsJsImpl> {
  static final _expando = Expando<Functions>();

  /// Creates a new Functions from a [jsObject].
  static Functions getInstance(functions_interop.FunctionsJsImpl jsObject) {
    if (jsObject == null) {
      return null;
    }
    return _expando[jsObject] ??= Functions._fromJsObject(jsObject);
  }

  Functions._fromJsObject(functions_interop.FunctionsJsImpl jsObject)
      : super.fromJsObject(jsObject);

  Functions get functions => getInstance(jsObject);

  HttpsCallable httpsCallable(String name,
      [functions_interop.HttpsCallableOptions options]) {
    functions_interop.HttpsCallableJsImpl httpCallableImpl;
    if (options != null) {
      httpCallableImpl = jsObject.httpsCallable(name, options);
    } else {
      httpCallableImpl = jsObject.httpsCallable(name);
    }
    return HttpsCallable.getInstance(httpCallableImpl);
  }

  void useFunctionsEmulator(String url) => jsObject.useFunctionsEmulator(url);
}

class HttpsCallable
    extends JsObjectWrapper<functions_interop.HttpsCallableJsImpl> {
  static final _expando = Expando<HttpsCallable>();

  /// Creates a new HttpsCallable from a [jsObject].
  static HttpsCallable getInstance(
      functions_interop.HttpsCallableJsImpl jsObject) {
    if (jsObject == null) {
      return null;
    }
    return _expando[jsObject] ??= HttpsCallable._fromJsObject(jsObject);
  }

  HttpsCallable._fromJsObject(functions_interop.HttpsCallableJsImpl jsObject)
      : super.fromJsObject(jsObject);

  Future<HttpsCallableResult> call([data]) =>
      handleThenable(jsObject.call(data == null ? null : jsify(data)))
          .then(HttpsCallableResult.getInstance);
}

class HttpsCallableResult
    extends JsObjectWrapper<functions_interop.HttpsCallableResultJsImpl> {
  static final _expando = Expando<HttpsCallableResult>();

  /// Creates a new HttpsCallableResult from a [jsObject].
  static HttpsCallableResult getInstance(
      functions_interop.HttpsCallableResultJsImpl jsObject) {
    if (jsObject == null) {
      return null;
    }
    return _expando[jsObject] ??= HttpsCallableResult._fromJsObject(jsObject);
  }

  HttpsCallableResult._fromJsObject(
      functions_interop.HttpsCallableResultJsImpl jsObject)
      : super.fromJsObject(jsObject);

  dynamic get data => dartify(jsObject.data);
}
