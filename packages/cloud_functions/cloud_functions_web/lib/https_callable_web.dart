// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:js_interop';

import 'package:cloud_functions_platform_interface/cloud_functions_platform_interface.dart';

import 'interop/functions.dart' as functions_interop;
import 'utils.dart';

/// A web specific implementation of [HttpsCallable].
class HttpsCallableWeb extends HttpsCallablePlatform {
  /// Constructor.
  HttpsCallableWeb(FirebaseFunctionsPlatform functions, this._webFunctions,
      String? origin, String? name, HttpsCallableOptions options, Uri? uri)
      : super(functions, origin, name, options, uri);

  final functions_interop.Functions _webFunctions;

  @override
  Future<dynamic> call([Object? parameters]) async {
    if (origin != null) {
      final uri = Uri.parse(origin!);

      _webFunctions.useFunctionsEmulator(uri.host, uri.port);
    }

    functions_interop.HttpsCallableOptions callableOptions =
        functions_interop.HttpsCallableOptions(
      timeout: options.timeout.inMilliseconds.toJS,
      limitedUseAppCheckTokens: options.limitedUseAppCheckToken.toJS,
    );

    late functions_interop.HttpsCallable callable;

    if (name != null) {
      callable = _webFunctions.httpsCallable(name!, callableOptions);
    } else if (uri != null) {
      callable = _webFunctions.httpsCallableUri(uri!, callableOptions);
    } else {
      throw ArgumentError('Either name or uri must be provided');
    }

    functions_interop.HttpsCallableResult response;

    final JSAny? parametersJS = parameters?.jsify();

    try {
      response = await callable.call(parametersJS);
    } catch (e, s) {
      throw convertFirebaseFunctionsException(e as JSObject, s);
    }

    return response.data;
  }
}
