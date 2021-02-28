// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_messaging_platform_interface/src/method_channel/method_channel_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';

typedef MethodCallCallback = dynamic Function(MethodCall methodCall);
typedef Callback = Function(MethodCall call);

void setupFirebaseMessagingMocks([Callback? customHandlers]) {
  TestWidgetsFlutterBinding.ensureInitialized();
  MethodChannelFirebase.channel.setMockMethodCallHandler((call) async {
    if (call.method == 'Firebase#initializeCore') {
      return [
        {
          'name': defaultFirebaseAppName,
          'options': {
            'apiKey': '123',
            'appId': '123',
            'messagingSenderId': '123',
            'projectId': '123',
          },
          'pluginConstants': {},
        }
      ];
    }
    if (call.method == 'Firebase#initializeApp') {
      return {
        'name': call.arguments['appName'],
        'options': call.arguments['options'],
        'pluginConstants': {},
      };
    }

    if (customHandlers != null) {
      customHandlers(call);
    }

    return null;
  });
}

void handleMethodCall(MethodCallCallback methodCallCallback) =>
    MethodChannelFirebaseMessaging.channel
        .setMockMethodCallHandler((call) async {
      return await methodCallCallback(call);
    });

Future<void> testExceptionHandling(String type, Function testMethod) async {
  try {
    await testMethod();
  } on FirebaseException catch (_) {
    if (type == 'PLATFORM' || type == 'EXCEPTION') {
      return;
    }
    fail(
        'testExceptionHandling: $testMethod threw unexpected FirebaseException');
  } catch (e) {
    fail('testExceptionHandling: $testMethod threw invalid exception $e');
  }
}
