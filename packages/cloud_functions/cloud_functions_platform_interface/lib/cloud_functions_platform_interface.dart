// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library cloud_functions_platform_interface;

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart' show required, visibleForTesting;

part 'src/https_callable.dart';
part 'src/https_callable_result.dart';
part 'src/method_channel_cloud_functions.dart';

/// The interface that implementations of `cloud_functions` must extend.
///
/// Platform implementations should extend this class rather than implement it
/// as `cloud_functions` does not consider newly added methods to be breaking
/// changes. Extending this class (using `extends`) ensures that the subclass
/// will get the default implementation, while platform implementations that
/// `implements` this interface will be broken by newly added
/// [CloudFunctionsPlatform] methods.
abstract class CloudFunctionsPlatform {
  /// Only mock implementations should set this to `true`.
  ///
  /// Mockito mocks implement this class with `implements` which is forbidden
  /// (see class docs). This property provides a backdoor for mocks to skip the
  /// verification that the class isn't implemented with `implements`.
  @visibleForTesting
  bool get isMock => false;

  /// The default instance of [CloudFunctionsPlatform] to use.
  ///
  /// Platform-specific plugins should override this with their own class
  /// that extends [CloudFunctionsPlatform] when they register themselves.
  ///
  /// Defaults to [MethodChannelCloudFunctions].
  static CloudFunctionsPlatform get instance => _instance;

  static CloudFunctionsPlatform _instance = MethodChannelCloudFunctions();

  // TODO(amirh): Extract common platform interface logic.
  // https://github.com/flutter/flutter/issues/43368
  static set instance(CloudFunctionsPlatform instance) {
    if (!instance.isMock) {
      try {
        instance._verifyProvidesDefaultImplementations();
      } on NoSuchMethodError catch (_) {
        throw AssertionError(
            'Platform interfaces must not be implemented with `implements`');
      }
    }
    _instance = instance;
  }

  /// This method ensures that [CloudFunctionsPlatform] isn't implemented with `implements`.
  ///
  /// See class docs for more details on why using `implements` to implement
  /// [CloudFunctionsPlatform] is forbidden.
  ///
  /// This private method is called by the [instance] setter, which should fail
  /// if the provided instance is a class implemented with `implements`.
  void _verifyProvidesDefaultImplementations() {}

  /// Gets an instance of a Callable HTTPS trigger in Cloud Functions.
  ///
  /// Can then be executed by calling `call()` on it.
  ///
  /// @param functionName The name of the callable function.
  HttpsCallable getHttpsCallable({@required String functionName}) {
    throw UnimplementedError('getHttpsCallable() is not implemented');
  }

  /// Changes this instance to point to a Cloud Functions emulator running locally.
  ///
  /// @param origin The origin of the local emulator, such as "//10.0.2.2:5005".
  CloudFunctionsPlatform useFunctionsEmulator({@required String origin}) {
    throw UnimplementedError('useFunctionsEmulator() is not implemented');
  }
}
