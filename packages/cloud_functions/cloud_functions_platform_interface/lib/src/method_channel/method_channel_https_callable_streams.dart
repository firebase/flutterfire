// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/services.dart';
import '../../cloud_functions_platform_interface.dart';
import 'package:cloud_functions_platform_interface/src/method_channel/utils/extensions.dart';

class MethodChannelHttpsCallableStreams<R>
    extends HttpsCallableStreamsPlatform<R> {
  MethodChannelHttpsCallableStreams(String? origin, String? name, Uri? uri)
      : _channel = EventChannel('plugins.flutter.io/firebase_functions/${name ?? uri?.toChannelPath()}'),
        super(origin, name, uri);

  final EventChannel _channel;

  @override
  Stream<T> stream<T>(Object? object) {
    return _channel.receiveBroadcastStream(object).cast<T>();
  }

  @override
  Future<R> get data => throw UnimplementedError();
}
