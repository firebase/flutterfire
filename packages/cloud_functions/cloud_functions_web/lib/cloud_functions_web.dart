// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cloud_functions_platform_interface/cloud_functions_platform_interface.dart';
import 'package:cloud_functions_web/https_callable_web.dart';
import 'package:firebase/firebase.dart' as firebase;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

/// Web implementation of [FirebaseFunctionsPlatform].
class FirebaseFunctionsWeb extends FirebaseFunctionsPlatform {
  /// Instance of functions from the web plugin
  final firebase.Functions _webFunctions;

  /// Create the default instance of the [FirebaseFunctionsPlatform] as a [FirebaseFunctionsWeb]
  static void registerWith(Registrar registrar) {
    FirebaseFunctionsPlatform.instance = FirebaseFunctionsWeb.instance;
  }

  /// Returns an instance of [FirebaseFunctionsWeb].
  static FirebaseFunctionsWeb get instance {
    return FirebaseFunctionsWeb._();
  }

  /// Stub initializer to allow the [registerWith] to create an instance without
  /// registering the web delegates or listeners.
  FirebaseFunctionsWeb._()
      : _webFunctions = null,
        super(null, null);

  /// The entry point for the [FirebaseFunctionsWeb] class.
  FirebaseFunctionsWeb({FirebaseApp app, String region})
      : _webFunctions = firebase.app(app?.name).functions(region),
        super(app, region);

  @override
  FirebaseFunctionsPlatform delegateFor({FirebaseApp app, String region}) {
    return FirebaseFunctionsWeb(app: app, region: region);
  }

  @override
  HttpsCallablePlatform httpsCallable(
      String origin, String name, HttpsCallableOptions options) {
    return HttpsCallableWeb(this, _webFunctions, origin, name, options);
  }
}
