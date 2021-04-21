// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

import '../../cloud_functions_platform_interface.dart';
import 'method_channel_https_callable.dart';

/// Method Channel delegate for [FirebaseFunctionsPlatform].
class MethodChannelFirebaseFunctions extends FirebaseFunctionsPlatform {
  /// Creates a new [MethodChannelFirebaseFunctions] instance with an [app] and/or
  /// [region].
  MethodChannelFirebaseFunctions({FirebaseApp? app, required String region})
      : super(app, region);

  /// Internal stub class initializer.
  ///
  /// When the user code calls a functions method, the real instance is
  /// then initialized via the [delegateFor] method.
  MethodChannelFirebaseFunctions._() : super(null, 'us-central1');

  /// Returns a stub instance to allow the platform interface to access
  /// the class instance statically.
  static MethodChannelFirebaseFunctions get instance {
    return MethodChannelFirebaseFunctions._();
  }

  /// The [MethodChannelFirebaseFunctions] method channel.
  static const MethodChannel channel = MethodChannel(
    'plugins.flutter.io/firebase_functions',
  );

  @override
  FirebaseFunctionsPlatform delegateFor(
      {FirebaseApp? app, required String region}) {
    return MethodChannelFirebaseFunctions(app: app, region: region);
  }

  @override
  HttpsCallablePlatform httpsCallable(
      String? origin, String name, HttpsCallableOptions options) {
    return MethodChannelHttpsCallable(this, origin, name, options);
  }
}
