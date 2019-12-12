// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:flutter/services.dart';
import 'package:meta/meta.dart' show visibleForTesting;

import '../interfaces/document_reference_platform.dart';

class MethodChannelDocumentReference extends DocumentReferencePlatform {
  MethodChannelDocumentReference() {
    channel.setMethodCallHandler(_callHandler);
  }

  @visibleForTesting
  static const MethodChannel channel = MethodChannel(
    'plugins.flutter.io/cloud_firestore',
  );

  void _callHandler(MethodCall call) {
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
