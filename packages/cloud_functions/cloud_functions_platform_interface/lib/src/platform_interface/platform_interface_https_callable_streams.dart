// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cloud_functions_platform_interface/cloud_functions_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// Interface for [HttpsCallableStream] implementations
///
/// A reference to a particular Callable HTTPS trigger in Cloud Functions.
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

  /// Streams data to the specified HTTPS endpoint.
  ///
  /// The data passed into the trigger can be any of the following types:
  ///
  /// `null`
  /// `String`
  /// `num`
  /// [List], where the contained objects are also one of these types.
  /// [Map], where the values are also one of these types.
  ///
  /// The request to the Cloud Functions backend made by this method
  /// automatically includes a Firebase Instance ID token to identify the app
  /// instance. If a user is logged in with Firebase Auth, an auth ID token for
  /// the user is also automatically included.
  Stream<dynamic> stream(Object? parameters);
}
