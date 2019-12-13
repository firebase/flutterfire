// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart' show visibleForTesting;

import '../interfaces/transaction_platform.dart';

class MethodChannelTransaction extends TransactionPlatform {
  MethodChannelTransaction() {
    channel.setMethodCallHandler(_callHandler);
  }

  @visibleForTesting
  static const MethodChannel channel = MethodChannel(
    'plugins.flutter.io/cloud_firestore',
  );

  Future<dynamic> _callHandler(MethodCall call) async {
    switch (call.method) {
      case 'DoTransaction':
        return _handleDoTransaction(call);
    }
  }

  void _handleDoTransaction(MethodCall call) {
    final int transactionId = call.arguments['transactionId'];
    // Do the transaction
  }
}
