// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of cloud_functions_platform_interface;

/// Exception that can be thrown by [MethodChannelCloudFunctions] to report
/// errors that occurred inside the channel. A convenience wrapper for [PlatformException].
class CloudFunctionsException implements Exception {
  CloudFunctionsException._(this.code, this.message, this.details);

  /// Error code reported by the platform
  final String code;

  /// Error message reported by the platform
  final String message;

  /// Additional info provided by the platform's exception
  final dynamic details;
}

/// [CloudFunctionsPlatform] implementation that delegates to a [MethodChannel].
class MethodChannelCloudFunctions extends CloudFunctionsPlatform {
  /// The [MethodChannel] to which calls will be delegated.
  @visibleForTesting
  static const MethodChannel channel = MethodChannel(
    'plugins.flutter.io/cloud_functions',
  );

  @override
  dynamic callCloudFunction({
    @required String appName,
    @required String functionName,
    String region,
    String origin,
    Duration timeout,
    dynamic parameters,
  }) async {
    try {
      final dynamic response = await channel
          .invokeMethod<dynamic>('CloudFunctions#call', <String, dynamic>{
        'app': appName,
        'region': region,
        'origin': origin,
        'timeoutMicroseconds': timeout?.inMicroseconds,
        'functionName': functionName,
        'parameters': parameters,
      });
      return response;
    } on PlatformException catch (e) {
      if (e.code == 'functionsError') {
        final String code = e.details['code'];
        final String message = e.details['message'];
        final dynamic details = e.details['details'];
        throw CloudFunctionsException._(code, message, details);
      } else {
        throw Exception('Unable to call function ' + functionName);
      }
    } catch (e) {
      rethrow;
    }
  }
}
