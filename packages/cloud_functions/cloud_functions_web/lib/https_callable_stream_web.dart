// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:js_interop';

import 'package:cloud_functions_platform_interface/cloud_functions_platform_interface.dart';
import 'package:cloud_functions_web/interop/functions_interop.dart' as interop;

import 'interop/functions.dart' as functions_interop;
import 'utils.dart';

class HttpsCallableStreamWeb extends HttpsCallableStreamsPlatform {
  HttpsCallableStreamWeb(
      FirebaseFunctionsPlatform functions,
      this._webFunctions,
      String? origin,
      String? name,
      HttpsCallableOptions options,
      Uri? uri)
      : super(functions, origin, name, options, uri);

  final functions_interop.Functions _webFunctions;

  @override
  Stream<dynamic> stream(Object? parameters) async* {
    if (origin != null) {
      final uri = Uri.parse(origin!);

      _webFunctions.useFunctionsEmulator(uri.host, uri.port);
    }

    late functions_interop.HttpsCallable callable;

    if (name != null) {
      callable = _webFunctions.httpsCallable(name!);
    } else if (uri != null) {
      callable = _webFunctions.httpsCallableUri(uri!);
    } else {
      throw ArgumentError('Either name or uri must be provided');
    }

    final JSAny? parametersJS = parameters?.jsify();
    interop.HttpsCallableStreamOptions callableStreamOptions =
        interop.HttpsCallableStreamOptions(
            limitedUseAppCheckTokens: options.limitedUseAppCheckToken.toJS);
    try {
      await for (final value
          in callable.stream(parametersJS, callableStreamOptions)) {
        yield value;
      }
    } catch (e, s) {
      throw convertFirebaseFunctionsException(e as JSObject, s);
    }
  }
}
