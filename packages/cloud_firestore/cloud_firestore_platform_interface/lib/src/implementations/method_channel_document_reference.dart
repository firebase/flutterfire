// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart' show visibleForTesting;

import './multi_method_channel.dart';
import '../interfaces/document_reference_platform.dart';

class MethodChannelDocumentReference extends DocumentReferencePlatform {
  MethodChannelDocumentReference(MultiMethodChannel channel) {
    MethodChannelDocumentReference._channel = channel;
    MethodChannelDocumentReference._channel.addMethodCallHandler('DocumentSnapshot', this._handleDocumentSnapshot);
  }

  @visibleForTesting
  static MultiMethodChannel get channel => MethodChannelDocumentReference._channel;
  static MultiMethodChannel _channel;

  Future<dynamic> _handleDocumentSnapshot(MethodCall call) {
    final int handle = call.arguments['handle'];
    // Get the documentObserver and broadcast a DocumentSnapshot
  }
}
