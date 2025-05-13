// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:js_interop';

import 'package:cloud_functions_platform_interface/cloud_functions_platform_interface.dart';
import 'package:cloud_functions_web/interop/functions_interop.dart' as interop;

import 'interop/functions.dart' as functions_interop;
import 'utils.dart';
import 'package:web/web.dart' as web;

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
    web.AbortSignal? signal;
    if (options.webAbortSignal != null) {
      signal = _createJsAbortSignal(options.webAbortSignal!);
    }
    interop.HttpsCallableStreamOptions callableStreamOptions =
        interop.HttpsCallableStreamOptions(
            limitedUseAppCheckTokens: options.limitedUseAppCheckToken.toJS,
            signal: signal);
    try {
      await for (final value
          in callable.stream(parametersJS, callableStreamOptions)) {
        yield value;
      }
    } catch (e, s) {
      throw convertFirebaseFunctionsException(e as JSObject, s);
    }
  }

  web.AbortSignal _createJsAbortSignal(AbortSignal signal) {
    try {
      switch (signal) {
        case TimeLimit(:final time):
          return web.AbortSignal.timeout(time.inMilliseconds);
        case Abort(:final reason):
          return web.AbortSignal.abort(reason.jsify());
        case Any(:final signals):
          final jsSignals = signals.map(_createJsAbortSignal).toList().toJS;
          return web.AbortSignal.any(jsSignals);
      }
    } catch (e, s) {
      throw convertFirebaseFunctionsException(e as JSObject, s);
    }
  }
}
