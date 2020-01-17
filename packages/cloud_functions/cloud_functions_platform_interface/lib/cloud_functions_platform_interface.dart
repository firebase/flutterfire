// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library cloud_functions_platform_interface;

import 'package:flutter/services.dart';
import 'package:meta/meta.dart' show required, visibleForTesting;
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

part 'src/method_channel_cloud_functions.dart';

/// The interface that implementations of `cloud_functions` must extend.
///
/// Platform implementations should extend this class rather than implement it
/// as `cloud_functions` does not consider newly added methods to be breaking
/// changes. Extending this class (using `extends`) ensures that the subclass
/// will get the default implementation, while platform implementations that
/// `implements` this interface will be broken by newly added
/// [CloudFunctionsPlatform] methods.
abstract class CloudFunctionsPlatform extends PlatformInterface {

  static final Object _token = Object();

  /// Constructs a CloudFunctionsPlatform
  CloudFunctionsPlatform(): super(token: _token);

  /// The default instance of [CloudFunctionsPlatform] to use.
  ///
  /// Platform-specific plugins should override this with their own class
  /// that extends [CloudFunctionsPlatform] when they register themselves.
  ///
  /// Defaults to [MethodChannelCloudFunctions].
  static CloudFunctionsPlatform get instance => _instance;

  static CloudFunctionsPlatform _instance = MethodChannelCloudFunctions();

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [CloudFunctionsPlatform] when they register themselves.
  // TODO(amirh): Extract common platform interface logic.
  // https://github.com/flutter/flutter/issues/43368
  static set instance(CloudFunctionsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Invokes the specified cloud function.
  ///
  /// The data passed into the cloud function can be any of the following types:
  ///
  /// `null`
  /// `String`
  /// `num`
  /// [List], where the contained objects are also one of these types.
  /// [Map], where the values are also one of these types.
  ///
  /// @param appName name of the Firebase application to which the function belongs
  /// @param functionName the function being called
  /// @param region the region in which the function will be called. If `null`, defaults to `us-central1`
  /// @param origin URL base of the function. If set, this can be used to send requests to a local emulator.
  /// @param timeout Request timeout. Defaults to 60 seconds this parameter is `null`.
  /// @param parameters The data payload for the function.
  dynamic callCloudFunction({
    @required String appName,
    @required String functionName,
    String region,
    String origin,
    Duration timeout,
    dynamic parameters,
  }) {
    throw UnimplementedError('callCloudFunction() has not been implemented');
  }
}
