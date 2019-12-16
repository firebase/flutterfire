// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart' show visibleForTesting, required;

import '../interfaces/query_platform.dart';
import '../types.dart';

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



  /// What does this method correspond to in the Firebase API?
  Future<PlatformQuerySnapshot> getDocuments(
    String app, {
    @required String path,
    bool isCollectionGroup,
    Map<String, dynamic> parameters,
    Source source,
  }) {
    return channel.invokeMapMethod<String, dynamic>(
      'Query#getDocuments',
      <String, dynamic>{
        'app': app,
        'path': path,
        'isCollectionGroup': isCollectionGroup,
        'parameters': parameters,
        'source': getSourceString(source),
      },
    ).then((Map<String, dynamic> response) {
      return PlatformQuerySnapshot(data: response);
    });
  }
}
