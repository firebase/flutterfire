// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart' show visibleForTesting;

import '../interfaces/document_reference_platform.dart';

class MethodChannelDocumentReference extends DocumentReferencePlatform {
  MethodChannelDocumentReference(StandardMessageCodec codec) {
    MethodChannelDocumentReference._channel = MethodChannel(
      'plugins.flutter.io/cloud_firestore',
      StandardMethodCodec(codec),
    );
    MethodChannelDocumentReference._channel.setMethodCallHandler(_callHandler);
  }

  @visibleForTesting
  static MethodChannel get channel => MethodChannelDocumentReference._channel;
  static MethodChannel _channel;

  Future<dynamic> _callHandler(MethodCall call) async {
    switch (call.method) {
      case 'DocumentSnapshot':
        return _handleDocumentSnapshot(call);
    }
  }

  void _handleDocumentSnapshot(MethodCall call) {
    final int handle = call.arguments['handle'];
    // Get the documentObserver and broadcast a DocumentSnapshot
  }
}
