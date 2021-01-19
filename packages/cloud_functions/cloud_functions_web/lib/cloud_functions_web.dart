// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cloud_functions_platform_interface/cloud_functions_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:firebase_core_web/firebase_core_web_interop.dart'
    as core_interop;
import 'https_callable_web.dart';
import 'interop/functions.dart' as functions_interop;

/// Web implementation of [FirebaseFunctionsPlatform].
class FirebaseFunctionsWeb extends FirebaseFunctionsPlatform {
  /// The entry point for the [FirebaseFunctionsWeb] class.
  FirebaseFunctionsWeb({FirebaseApp? app, required String region})
      : _webFunctions = functions_interop.getFunctionsInstance(
            core_interop.app(app?.name), region),
        super(app, region);

  /// Stub initializer to allow the [registerWith] to create an instance without
  /// registering the web delegates or listeners.
  FirebaseFunctionsWeb._()
      : _webFunctions = null,
        super(null, 'us-central1');

  /// Instance of functions from the web plugin
  final functions_interop.Functions? _webFunctions;

  /// Create the default instance of the [FirebaseFunctionsPlatform] as a [FirebaseFunctionsWeb]
  static void registerWith(Registrar registrar) {
    FirebaseFunctionsPlatform.instance = FirebaseFunctionsWeb.instance;
  }

  /// Returns an instance of [FirebaseFunctionsWeb].
  static FirebaseFunctionsWeb get instance {
    return FirebaseFunctionsWeb._();
  }

  @override
  FirebaseFunctionsPlatform delegateFor(
      {FirebaseApp? app, required String region}) {
    return FirebaseFunctionsWeb(app: app, region: region);
  }

  @override
  HttpsCallablePlatform httpsCallable(
      String? origin, String name, HttpsCallableOptions options) {
    return HttpsCallableWeb(this, _webFunctions!, origin, name, options);
  }
}
