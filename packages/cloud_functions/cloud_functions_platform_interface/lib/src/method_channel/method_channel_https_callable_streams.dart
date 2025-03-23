// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_functions_platform_interface/src/method_channel/method_channel_firebase_functions.dart';
import 'package:cloud_functions_platform_interface/src/method_channel/utils/exception.dart';
import 'package:flutter/services.dart';
import '../../cloud_functions_platform_interface.dart';

class MethodChannelHttpsCallableStreams<R>
    extends HttpsCallableStreamsPlatform<R> {
  MethodChannelHttpsCallableStreams(FirebaseFunctionsPlatform functions,
      String? origin, String? name, Uri? uri)
      : _transformedUri = uri?.pathSegments.join('_').replaceAll('.', '_'),
        super(functions, origin, name, uri) {
    _eventChannelId = name ?? _transformedUri ?? '';
    _channel =
        EventChannel('plugins.flutter.io/firebase_functions/$_eventChannelId');
  }

  late final EventChannel _channel;
  final String? _transformedUri;
  late String _eventChannelId;

  @override
  Stream<dynamic> stream(Object? parameters) async* {
    try {
      await _registerEventChannelOnNative();
      final eventData = {
        'appName': functions.app!.name,
        'functionName': name,
        'functionUri': uri?.toString(),
        'origin': origin,
        'region': functions.region,
        'parameters': parameters,
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

  Future<void> _registerEventChannelOnNative() async {
    await MethodChannelFirebaseFunctions.channel.invokeMethod(
        'FirebaseFunctions#registerEventChannel', <String, dynamic>{
      'eventChannelId': _eventChannelId,
    });
  }

  @override
  Future<dynamic> get data async {
    final result = await MethodChannelFirebaseFunctions.channel
        .invokeMethod('FirebaseFunctions#getCompleteResult');
    if (result is Map) {
      return Map<String, dynamic>.from(result);
    }
    return result;
  }
}
