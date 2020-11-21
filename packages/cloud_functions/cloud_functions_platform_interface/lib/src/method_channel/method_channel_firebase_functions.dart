// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cloud_functions_platform_interface/cloud_functions_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

import 'method_channel_https_callable.dart';

/// Method Channel delegate for [FirebaseFunctionsPlatform].
class MethodChannelFirebaseFunctions extends FirebaseFunctionsPlatform {
  /// Returns a stub instance to allow the platform interface to access
  /// the class instance statically.
  static MethodChannelFirebaseFunctions get instance {
    return MethodChannelFirebaseFunctions._();
  }

  /// The [MethodChannelFirebaseAuth] method channel.
  static const MethodChannel channel = MethodChannel(
    'plugins.flutter.io/firebase_functions',
  );

  /// Internal stub class initializer.
  ///
  /// When the user code calls a functions method, the real instance is
  /// then initialized via the [delegateFor] method.
  MethodChannelFirebaseFunctions._() : super(null, null);

  /// Creates a new [MethodChannelFirebaseFunctions] instance with an [app] and/or
  /// [region].
  MethodChannelFirebaseFunctions({FirebaseApp app, String region})
      : super(app, region);

  FirebaseFunctionsPlatform delegateFor({FirebaseApp app, String region}) {
    return MethodChannelFirebaseFunctions(app: app, region: region);
  }

  @override
  httpsCallable(String origin, String name, HttpsCallableOptions options) {
    return MethodChannelHttpsCallable(this, origin, name, options);
  }
}
