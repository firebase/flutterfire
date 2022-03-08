// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import '../../cloud_functions_platform_interface.dart';
import 'method_channel_firebase_functions.dart';

import 'utils/exception.dart';

/// Method Channel delegate for [HttpsCallablePlatform].
class MethodChannelHttpsCallable extends HttpsCallablePlatform {
  /// Creates a new [MethodChannelHttpsCallable] instance.
  MethodChannelHttpsCallable(FirebaseFunctionsPlatform functions,
      String? origin, String name, HttpsCallableOptions options)
      : super(functions, origin, name, options);

  @override
  Future<dynamic> call([Object? parameters]) async {
    try {
      Object? result = await MethodChannelFirebaseFunctions.channel
          .invokeMethod('FirebaseFunctions#call', <String, dynamic>{
        'appName': functions.app!.name,
        'functionName': name,
        'origin': origin,
        'region': functions.region,
        'timeout': options.timeout.inMilliseconds,
        'parameters': parameters,
      });

      if (result is Map) {
        return Map<String, dynamic>.from(result);
      } else {
        return result;
      }
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }
}
