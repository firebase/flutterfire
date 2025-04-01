// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:js_interop';

import 'package:cloud_functions_platform_interface/cloud_functions_platform_interface.dart';

import 'interop/functions.dart' as functions_interop;

class HttpsCallableStreamWeb extends HttpsCallableStreamsPlatform {
  HttpsCallableStreamWeb(
      super.functions, this._webFunctions, super.origin, super.name, super.uri);

  final functions_interop.Functions _webFunctions;

  @override
  Future get data => throw UnimplementedError();

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

    await for (final value in  callable.stream(parametersJS)){
      yield value;
    }
  }
}
