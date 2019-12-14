// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart' show visibleForTesting;

import '../interfaces/query_platform.dart';

class MethodChannelQuery extends QueryPlatform {
  MethodChannelQuery(StandardMessageCodec codec) {
    MethodChannelQuery._channel = MethodChannel(
      'plugins.flutter.io/cloud_firestore',
      StandardMethodCodec(codec),
    );
    MethodChannelQuery._channel.setMethodCallHandler(_callHandler);
  }

  @visibleForTesting
  static MethodChannel get channel => MethodChannelQuery._channel;
  static MethodChannel _channel;

  Future<dynamic> _callHandler(MethodCall call) async {
    switch (call.method) {
      case 'QuerySnapshot':
        return _handleQuerySnapshot(call);
    }
  }

  void _handleQuerySnapshot(MethodCall call) {
    final int handle = call.arguments['handle'];
    // Get the documentObserver and broadcast a QuerySnapshot
  }
}
