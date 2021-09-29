// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_functions_platform_interface/src/https_callable_options.dart';
import 'package:cloud_functions_platform_interface/src/method_channel/method_channel_firebase_functions.dart';
import 'package:cloud_functions_platform_interface/src/method_channel/method_channel_https_callable.dart';
import 'package:cloud_functions_platform_interface/src/platform_interface/platform_interface_firebase_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mock.dart';

void main() {
  setupFirebaseFunctionsMocks();

  group('$MethodChannelFirebaseFunctions', () {
    FirebaseApp? app;
    FirebaseFunctionsPlatform? functions;

    setUpAll(() async {
      app = await Firebase.initializeApp();
      functions =
          MethodChannelFirebaseFunctions(app: app, region: 'us-central1');
    });

    test('channel', () {
      expect(MethodChannelFirebaseFunctions.channel.name,
          'plugins.flutter.io/firebase_functions');
    });

    test('instance', () {
      final result = MethodChannelFirebaseFunctions.instance;
      expect(result, isA<MethodChannelFirebaseFunctions>());
      expect(result, isA<FirebaseFunctionsPlatform>());
      expect(result.region, equals('us-central1'));
    });

    test('delegateFor', () {
      final testFunctions =
          TestMethodChannelFirebaseFunctions(app: app, region: 'us-central1');
      final result =
          testFunctions.delegateFor(app: app, region: 'europe-west1');
      expect(result, isA<MethodChannelFirebaseFunctions>());
      expect(result.app, isA<FirebaseApp>());
      expect(result.app, equals(app));
      expect(result.region, equals('europe-west1'));
    });

    test('httpsCallable', () {
      const testOrigin = 'http://localhost:5000';
      const testFunctionName = 'test_function_name';
      final callable = functions!
          .httpsCallable(testOrigin, testFunctionName, HttpsCallableOptions());
      expect(callable, isA<MethodChannelHttpsCallable>());
      expect(callable.origin, equals(testOrigin));
      expect(callable.name, equals(testFunctionName));
    });
  });
}

class TestMethodChannelFirebaseFunctions
    extends MethodChannelFirebaseFunctions {
  TestMethodChannelFirebaseFunctions({FirebaseApp? app, required String region})
      : super(app: app, region: region);
}
