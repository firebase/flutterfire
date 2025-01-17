// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_auth_platform_interface/src/method_channel/method_channel_firebase_auth.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

typedef MethodCallCallback = dynamic Function(MethodCall methodCall);
typedef Callback = void Function(MethodCall call);

// mock values
const String TEST_PHONE_NUMBER = '5555555555';

int mockHandleId = 0;
int get nextMockHandleId => mockHandleId++;

void setupFirebaseAuthMocks([Callback? customHandlers]) {
  TestWidgetsFlutterBinding.ensureInitialized();

  setupFirebaseCoreMocks();
}

void handleEventChannel(
  final String name, [
  List<MethodCall>? log,
]) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(MethodChannel(name),
          (MethodCall methodCall) async {
    log?.add(methodCall);
    switch (methodCall.method) {
      case 'listen':
        break;
      case 'cancel':
      default:
        return null;
    }
    return null;
  });
}

Future<void> injectEventChannelResponse(
  String channelName,
  Map<String, dynamic> event,
) async {
  await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .handlePlatformMessage(
    channelName,
    MethodChannelFirebaseAuth.channel.codec.encodeSuccessEnvelope(event),
    (_) {},
  );
}

void handleMethodCall(MethodCallCallback methodCallCallback) =>
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(MethodChannelFirebaseAuth.channel,
            (call) async {
      return await methodCallCallback(call);
    });

Future<void> simulateEvent(String name, Map<String, dynamic>? user) async {
  await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .handlePlatformMessage(
    MethodChannelFirebaseAuth.channel.name,
    MethodChannelFirebaseAuth.channel.codec.encodeMethodCall(
      MethodCall(
        name,
        <String, dynamic>{'user': user, 'appName': defaultFirebaseAppName},
      ),
    ),
    (_) {},
  );
}

Future<void> testExceptionHandling(
  String type,
  void Function() testMethod,
) async {
  await expectLater(
    () async => testMethod(),
    anyOf([
      completes,
      if (type == 'PLATFORM' || type == 'EXCEPTION')
        throwsA(isA<FirebaseAuthException>()),
    ]),
  );
}
