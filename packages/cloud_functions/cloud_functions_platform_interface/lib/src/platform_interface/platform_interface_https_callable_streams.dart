// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cloud_functions_platform_interface/cloud_functions_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class HttpsCallableStreamsPlatform extends PlatformInterface {
  HttpsCallableStreamsPlatform(
    this.functions,
    this.origin,
    this.name,
    this.options,
    this.uri,
  )   : assert(name != null || uri != null),
        super(token: _token);

  static final Object _token = Object();

  static void verify(HttpsCallableStreamsPlatform instance) {
    PlatformInterface.verify(instance, _token);
  }

  /// The [FirebaseFunctionsPlatform] instance.
  final FirebaseFunctionsPlatform functions;

  /// The [origin] of the local emulator, such as "http://localhost:5001"
  final String? origin;

  /// The name of the function (required, non-nullable)
  final String? name;

  /// The URI of the function for 2nd gen functions
  final Uri? uri;

  /// Used to set the options for this instance.
  HttpsCallableOptions options;

  Stream<dynamic> stream(Object? parameters);
}
