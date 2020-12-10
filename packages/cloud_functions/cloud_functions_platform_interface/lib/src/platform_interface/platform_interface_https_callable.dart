// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:cloud_functions_platform_interface/cloud_functions_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// Interface for [HttpsCallable] implementations.
///
/// A reference to a particular Callable HTTPS trigger in Cloud Functions.
abstract class HttpsCallablePlatform extends PlatformInterface {
  /// Creates a new [HttpsCallablePlatform] instance.
  HttpsCallablePlatform(this.functions, this.origin, this.name, this.options)
      : super(token: _token);

  static final Object _token = Object();

  /// Throws an [AssertionError] if [instance] does not extend
  /// [HttpsCallablePlatform].
  ///
  /// This is used by the app-facing [HttpsCallable] to ensure that
  /// the object in which it's going to delegate calls has been
  /// constructed properly.
  static verifyExtends(HttpsCallablePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
  }

  /// The [FirebaseFunctionsPlatform] instance.
  final FirebaseFunctionsPlatform functions;

  /// The [origin] of the local emulator, such as "http://localhost:5001"
  final String origin;

  /// The name of the function
  final String name;

  /// Used to set the options for this instance.
  HttpsCallableOptions options;

  /// Executes this Callable HTTPS trigger asynchronously.
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
  Future<dynamic> call([dynamic parameters]) {
    throw UnimplementedError('call() is not implemented');
  }

  /// Returns the timeout for this instance.
  Duration get timeout {
    return options?.timeout;
  }

  /// Changes the timeout for calls from this instances.
  set timeout(Duration duration) {
    options = HttpsCallableOptions(timeout: duration);
  }
}
