// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_performance_platform_interface/src/method_channel/method_channel_firebase_performance.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

typedef MethodCallCallback = dynamic Function(MethodCall methodCall);
typedef Callback = void Function(MethodCall call);

int mockHandleId = 0;
int get nextMockHandleId => mockHandleId++;

void setupFirebasePerformanceMocks([Callback? customHandlers]) {
  TestWidgetsFlutterBinding.ensureInitialized();

  setupFirebaseCoreMocks();
}

void handleMethodCall(MethodCallCallback methodCallCallback) =>
    MethodChannelFirebasePerformance.channel
        .setMockMethodCallHandler((call) async {
      return await methodCallCallback(call);
    });

Future<void> testExceptionHandling(
  String type,
  void Function() testMethod,
) async {
  await expectLater(
    () async => testMethod(),
    anyOf([
      completes,
      if (type == 'PLATFORM' || type == 'EXCEPTION')
        throwsA(isA<FirebaseException>())
    ]),
  );
}
