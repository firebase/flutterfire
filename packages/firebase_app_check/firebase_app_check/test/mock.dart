// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_app_check_platform_interface/firebase_app_check_platform_interface.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

typedef Callback = void Function(MethodCall call);

final List<MethodCall> methodCallLog = <MethodCall>[];

void setupFirebaseAppCheckMocks([Callback? customHandlers]) {
  TestWidgetsFlutterBinding.ensureInitialized();

  setupFirebaseCoreMocks();

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(MethodChannelFirebaseAppCheck.channel,
          (MethodCall methodCall) async {
    if (methodCall.method != 'FirebaseAppCheck#registerTokenListener') {
      methodCallLog.add(methodCall);
    }

    switch (methodCall.method) {
      case 'FirebaseAppCheck#registerTokenListener':
        return 'channelName';
      case 'FirebaseAppCheck#getToken':
        return 'test-token';
      default:
        return false;
    }
  });
}
