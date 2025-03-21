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
      : _eventChannelId =
            uri?.pathSegments.join('_').replaceAll('.', '_') ?? '',
        super(functions, origin, name, uri) {
    _channel = EventChannel(
        'plugins.flutter.io/firebase_functions/${name ?? _eventChannelId}');
  }

  late final EventChannel _channel;
  final String _eventChannelId;

  @override
  Stream<T> stream<T>(Object? object) async* {
    try {
      await MethodChannelFirebaseFunctions.channel.invokeMethod(
          'FirebaseFunctions#setEventChannelId', <String, dynamic>{
        'eventChannelId': _eventChannelId,
        'appName': functions.app!.name,
        'functionName': name,
        'functionUri': uri?.toString(),
        'origin': origin,
      });
      yield* _channel.receiveBroadcastStream(object).cast<T>();
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<R> get data => throw UnimplementedError();
}
