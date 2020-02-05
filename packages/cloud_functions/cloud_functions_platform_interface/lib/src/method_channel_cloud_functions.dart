// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of cloud_functions_platform_interface;

/// [CloudFunctionsPlatform] implementation that delegates to a [MethodChannel].
class MethodChannelCloudFunctions extends CloudFunctionsPlatform {
  /// The [MethodChannel] to which calls will be delegated.
  @visibleForTesting
  static const MethodChannel channel = MethodChannel(
    'plugins.flutter.io/cloud_functions',
  );

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
  }) =>
      channel.invokeMethod<dynamic>('CloudFunctions#call', <String, dynamic>{
        'app': appName,
        'region': region,
        'origin': origin,
        'timeoutMicroseconds': timeout?.inMicroseconds,
        'functionName': functionName,
        'parameters': parameters,
      });
}
