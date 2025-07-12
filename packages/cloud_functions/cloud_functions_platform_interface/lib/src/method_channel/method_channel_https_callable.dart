// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';

import '../../cloud_functions_platform_interface.dart';
import 'method_channel_firebase_functions.dart';
import 'utils/exception.dart';

/// Method Channel delegate for [HttpsCallablePlatform].
class MethodChannelHttpsCallable extends HttpsCallablePlatform {
  /// Creates a new [MethodChannelHttpsCallable] instance.
  MethodChannelHttpsCallable(FirebaseFunctionsPlatform functions,
      String? origin, String? name, HttpsCallableOptions options, Uri? uri)
      : _transformedUri = uri?.pathSegments.join('_').replaceAll('.', '_'),
        super(functions, origin, name, options, uri) {
    _eventChannelId = name ?? _transformedUri ?? '';
    _channel =
        EventChannel('plugins.flutter.io/firebase_functions/$_eventChannelId');
  }

  late final EventChannel _channel;
  final String? _transformedUri;
  late String _eventChannelId;

  @override
  Future<dynamic> call([Object? parameters]) async {
    try {
      Object? result = await MethodChannelFirebaseFunctions.pigeonChannel
          .call(<String, dynamic>{
        'appName': functions.app!.name,
        'functionName': name,
        'functionUri': uri?.toString(),
        'origin': origin,
        'region': functions.region,
        'timeout': options.timeout.inMilliseconds,
        'parameters': parameters,
        'limitedUseAppCheckToken': options.limitedUseAppCheckToken,
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

  @override
  Stream<dynamic> stream(Object? parameters) async* {
    try {
      await MethodChannelFirebaseFunctions.pigeonChannel
          .registerEventChannel(<String, Object>{
        'eventChannelId': _eventChannelId,
        'appName': functions.app!.name,
        'region': functions.region,
      });
      final eventData = {
        'functionName': name,
        'functionUri': uri?.toString(),
        'origin': origin,
        'parameters': parameters,
        'limitedUseAppCheckToken': options.limitedUseAppCheckToken,
        'timeout': options.timeout.inMilliseconds,
      };
      yield* _channel.receiveBroadcastStream(eventData).map((message) {
        if (message is Map) {
          return Map<String, dynamic>.from(message);
        }
        return message;
      });
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }
}
