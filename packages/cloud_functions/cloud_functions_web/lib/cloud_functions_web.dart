// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:cloud_functions_platform_interface/cloud_functions_platform_interface.dart';
import 'package:firebase/firebase.dart' as firebase;
import 'package:flutter/foundation.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void _debugLog(String message) {
  print('DBL CFW: $message');
}

/// Web implementation of [CloudFunctionsPlatform]
class CloudFunctionsWeb extends CloudFunctionsPlatform {
  /// Create the default instance of the [CloudFunctionsPlatform] as a [CloudFunctionsWeb]
  static void registerWith(Registrar registrar) {
    CloudFunctionsPlatform.instance = CloudFunctionsWeb();
  }

  /// Invokes the specified cloud function.
  ///
  /// The required parameters, [appName] and [functionName], specify which
  /// cloud function will be called.
  ///
  /// The rest of the parameters are optional and used to invoke the function
  /// with something other than the defaults. [region] defaults to `us-central1`
  /// and [timeout] defaults to 60 seconds.
  ///
  /// The [origin] parameter may be used to provide the base URL for the function.
  /// This can be used to send requests to a local emulator.
  ///
  /// The data passed into the cloud function via [parameters] can be any of the following types:
  ///
  /// `null`
  /// `String`
  /// `num`
  /// [List], where the contained objects are also one of these types.
  /// [Map], where the values are also one of these types.
  @override
  Future<dynamic> callCloudFunction({
    @required String appName,
    @required String functionName,
    String region,
    String origin,
    Duration timeout,
    dynamic parameters,
  }) {
    _debugLog('In callCloudFunction of CloudFunctionsWeb');
    dynamic app = firebase.app(appName);
    _debugLog('Got app: $app');
    dynamic functions = firebase.functions(app);
    _debugLog('got a functions object: ${functions}');
    if (origin != null) {
      functions.useFunctionsEmulator(origin);
    }
    firebase.HttpsCallable hc;
    if (timeout != null) {
      _debugLog('timeout is not null: ${timeout}');
      hc = functions.httpsCallable(functionName,
          firebase.HttpsCallableOptions(timeout: timeout.inMicroseconds));
    } else {
      _debugLog('timeout is null');
      hc = functions.httpsCallable(functionName);
    }
    _debugLog('About to call call() on ${hc}');
    return hc.call(parameters).then((result) {
      return result.data;
    });
  }
}
