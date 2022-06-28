// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:js_util' as util;

import 'package:cloud_functions_platform_interface/cloud_functions_platform_interface.dart';

import 'interop/functions.dart' as functions_interop;
import 'utils.dart';

/// A web specific implementation of [HttpsCallable].
class HttpsCallableWeb extends HttpsCallablePlatform {
  /// Constructor.
  HttpsCallableWeb(FirebaseFunctionsPlatform functions, this._webFunctions,
      String? origin, String name, HttpsCallableOptions options)
      : super(functions, origin, name, options);

  final functions_interop.Functions _webFunctions;

  @override
  Future<dynamic> call([dynamic parameters]) async {
    if (origin != null) {
      final uri = Uri.parse(origin!);

      _webFunctions.useFunctionsEmulator(uri.host, uri.port);
    }

    functions_interop.HttpsCallableOptions callableOptions =
        functions_interop.HttpsCallableOptions(
            timeout: options.timeout.inMilliseconds);

    functions_interop.HttpsCallable callable =
        _webFunctions.httpsCallable(name, callableOptions);

    functions_interop.HttpsCallableResult response;
    var input = parameters;
    if ((input is Map) || (input is Iterable)) {
      input = util.jsify(parameters);
    }

    try {
      response = await callable.call(input);
    } catch (e, s) {
      throw convertFirebaseFunctionsException(e, s);
    }

    return response.data;
  }
}
