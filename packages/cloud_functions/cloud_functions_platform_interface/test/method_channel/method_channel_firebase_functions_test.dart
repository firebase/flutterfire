// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_functions_platform_interface/src/https_callable_options.dart';
import 'package:cloud_functions_platform_interface/src/method_channel/method_channel_firebase_functions.dart';
import 'package:cloud_functions_platform_interface/src/method_channel/method_channel_https_callable.dart';
import 'package:cloud_functions_platform_interface/src/platform_interface/platform_interface_firebase_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import '../mock.dart';

void main() {
  setupFirebaseFunctionsMocks();
  FirebaseFunctionsPlatform functions;

  group('$MethodChannelFirebaseFunctions', () {
    FirebaseApp app;

    setUpAll(() async {
      app = await Firebase.initializeApp();
      functions = MethodChannelFirebaseFunctions(app: app);
    });

    test('channel', () {
      expect(MethodChannelFirebaseFunctions.channel.name,
          'plugins.flutter.io/firebase_functions');
    });

    test('instance', () {
      final result = MethodChannelFirebaseFunctions.instance;
      expect(result, isA<MethodChannelFirebaseFunctions>());
      expect(result, isA<FirebaseFunctionsPlatform>());
    });

    test('delegateFor', () {
      final testFunctions = TestMethodChannelFirebaseFunctions(app);
      final result = testFunctions.delegateFor(app: app, region: 'uk');
      expect(result, isA<MethodChannelFirebaseFunctions>());
      expect(result.app, isA<FirebaseApp>());
    });

    test('httpsCallable', () {
      final result =
          functions.httpsCallable('test', 'test', HttpsCallableOptions());
      expect(result, isA<MethodChannelHttpsCallable>());
    });
  });
}

class TestMethodChannelFirebaseFunctions
    extends MethodChannelFirebaseFunctions {
  TestMethodChannelFirebaseFunctions(FirebaseApp app) : super(app: app);
}
