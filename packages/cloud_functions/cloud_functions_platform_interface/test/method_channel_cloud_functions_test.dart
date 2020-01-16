// Copyright 2018-2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cloud_functions_platform_interface/cloud_functions_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$CloudFunctionsPlatform', () {
    final List<MethodCall> log = <MethodCall>[];

    setUp(() async {
      MethodChannelCloudFunctions.channel
          .setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'FirebaseFunctions#call':
            return <String, dynamic>{
              'foo': 'bar',
            };
          default:
            return true;
        }
      });
      log.clear();
    });

    test('call', () async {
      await CloudFunctionsPlatform.instance
          .getHttpsCallable(functionName: 'baz')
          .call();
      final HttpsCallable callable = MethodChannelCloudFunctions(
              app: FirebaseApp(name: '1337'), region: 'space')
          .getHttpsCallable(functionName: 'qux')
            ..timeout = const Duration(days: 300);
      await callable.call(<String, dynamic>{
        'quux': 'quuz',
      });
      await CloudFunctionsPlatform.instance
          .useFunctionsEmulator(origin: 'http://localhost:5001')
          .getHttpsCallable(functionName: 'bez')
          .call();
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'CloudFunctions#call',
            arguments: <String, dynamic>{
              'app': '[DEFAULT]',
              'region': null,
              'origin': null,
              'functionName': 'baz',
              'timeoutMicroseconds': null,
              'parameters': null,
            },
          ),
          isMethodCall(
            'CloudFunctions#call',
            arguments: <String, dynamic>{
              'app': '1337',
              'region': 'space',
              'origin': null,
              'functionName': 'qux',
              'timeoutMicroseconds': (const Duration(days: 300)).inMicroseconds,
              'parameters': <String, dynamic>{'quux': 'quuz'},
            },
          ),
          isMethodCall(
            'CloudFunctions#call',
            arguments: <String, dynamic>{
              'app': '[DEFAULT]',
              'region': null,
              'origin': 'http://localhost:5001',
              'functionName': 'bez',
              'timeoutMicroseconds': null,
              'parameters': null,
            },
          ),
        ],
      );
    });
  });
}
