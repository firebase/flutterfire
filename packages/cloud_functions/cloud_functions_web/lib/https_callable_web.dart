// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:js_util' as util;

import 'package:cloud_functions_platform_interface/cloud_functions_platform_interface.dart';
import 'package:cloud_functions_web/utils.dart';
import 'package:firebase/firebase.dart' as firebase;
import 'package:firebase/src/utils.dart' show dartify;

/// A web specific implementation of [HttpsCallable].
class HttpsCallableWeb extends HttpsCallablePlatform {
  /// Constructor.
  HttpsCallableWeb(FirebaseFunctionsPlatform functions, this._webFunctions,
      String origin, String name, HttpsCallableOptions options)
      : super(functions, origin, name, options);

  final firebase.Functions _webFunctions;

  @override
  Future<dynamic> call([dynamic parameters]) async {
    if (origin != null) {
      _webFunctions.useFunctionsEmulator(origin);
    }

    firebase.HttpsCallableOptions callableOptions =
        firebase.HttpsCallableOptions(timeout: timeout?.inMilliseconds);

    firebase.HttpsCallable callable =
        _webFunctions.httpsCallable(name, callableOptions);

    var response;
    var input = parameters;
    if ((input is Map) || (input is Iterable)) {
      input = util.jsify(parameters);
    }
    var jsPromise = callable.jsObject.call(input);
    try {
      response = await util.promiseToFuture(jsPromise);
    } catch (e, s) {
      throw throwFirebaseFunctionsException(e, s);
    }

    return dartify(util.getProperty(response, 'data'));
  }
}
