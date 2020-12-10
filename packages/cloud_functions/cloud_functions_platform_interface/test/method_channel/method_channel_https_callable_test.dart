// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_functions_platform_interface/cloud_functions_platform_interface.dart';
import 'package:cloud_functions_platform_interface/src/https_callable_options.dart';
import 'package:cloud_functions_platform_interface/src/method_channel/method_channel_firebase_functions.dart';
import 'package:cloud_functions_platform_interface/src/method_channel/method_channel_https_callable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import '../mock.dart';

void main() {
  setupFirebaseFunctionsMocks();

  MethodChannelFirebaseFunctions functions;
  MethodChannelHttpsCallable httpsCallable;
  final List<MethodCall> logger = <MethodCall>[];

  // mock props
  bool mockPlatformExceptionThrown = false;
  bool mockExceptionThrown = false;
  String kName = 'test_name';
  String kOrigin = 'test_origin';
  dynamic kParameters = {'foo': 'bar'};
  HttpsCallableOptions kOptions =
      HttpsCallableOptions(timeout: Duration(minutes: 1));
  String kPlatformExceptionMessage = 'Mock platform exception thrown';

  group('$MethodChannelHttpsCallable', () {
    setUpAll(() async {
      FirebaseApp app = await Firebase.initializeApp();

      handleMethodCall((call) async {
        logger.add(call);
        if (mockExceptionThrown) {
          throw Exception();
        } else if (mockPlatformExceptionThrown) {
          throw PlatformException(
              code: 'UNKNOWN', message: kPlatformExceptionMessage);
        }

        switch (call.method) {
          case 'FirebaseFunctions#call':
            return kParameters;
          default:
            return null;
        }
      });

      functions = MethodChannelFirebaseFunctions(app: app);
      httpsCallable = MethodChannelHttpsCallable(
        functions,
        kOrigin,
        kName,
        kOptions,
      );
    });

    setUp(() async {
      mockPlatformExceptionThrown = false;
      mockExceptionThrown = false;
      httpsCallable.options = kOptions;

      logger.clear();
    });

    group('constructor', () {
      test('should create an instance', () {
        expect(httpsCallable, isInstanceOf<MethodChannelHttpsCallable>());
        expect(httpsCallable, isInstanceOf<HttpsCallablePlatform>());
      });

      test('should set name', () {
        expect(httpsCallable.name, isInstanceOf<String>());
        expect(httpsCallable.name, kName);
      });

      test('should set origin', () {
        expect(httpsCallable.origin, isInstanceOf<String>());
        expect(httpsCallable.origin, kOrigin);
      });

      test('should set options', () {
        expect(httpsCallable.options, isInstanceOf<HttpsCallableOptions>());
        expect(httpsCallable.options.timeout, isInstanceOf<Duration>());
        expect(httpsCallable.options.timeout.inMinutes, 1);
      });

      test('should set timeout', () {
        expect(httpsCallable.timeout, isInstanceOf<Duration>());
        expect(httpsCallable.timeout.inMinutes, 1);
      });
    });

    group('options', () {
      test('should set options', () {
        expect(httpsCallable.options, isInstanceOf<HttpsCallableOptions>());
        expect(httpsCallable.options.timeout, isInstanceOf<Duration>());
        expect(httpsCallable.options.timeout.inMinutes, 1);
      });

      test('handles null value', () {
        httpsCallable.options = null;
        expect(httpsCallable.options, isNull);
      });
    });

    group('timeout', () {
      test('set value', () {
        httpsCallable.timeout = Duration(minutes: 2);
        expect(httpsCallable.timeout, isInstanceOf<Duration>());
        expect(httpsCallable.timeout.inMinutes, 2);
      });

      test('handles null value', () {
        httpsCallable.timeout = null;
        expect(httpsCallable.timeout, isNull);
      });
    });

    group('call', () {
      test('invokes native method with correct args', () async {
        final result = await httpsCallable.call(kParameters);

        expect(result, isA<dynamic>());
        expect(result['foo'], 'bar');

        // check native method was called
        expect(logger, <Matcher>[
          isMethodCall(
            'FirebaseFunctions#call',
            arguments: <String, dynamic>{
              'appName': functions.app.name,
              'functionName': httpsCallable.name,
              'origin': httpsCallable.origin,
              'region': functions.region,
              'timeout': httpsCallable.timeout.inMilliseconds,
              'parameters': kParameters,
            },
          ),
        ]);
      });

      test('invokes native method when timeout is null', () async {
        httpsCallable.timeout = null;

        await httpsCallable.call(kParameters);

        // check native method was called
        expect(logger, <Matcher>[
          isMethodCall(
            'FirebaseFunctions#call',
            arguments: <String, dynamic>{
              'appName': functions.app.name,
              'functionName': httpsCallable.name,
              'origin': httpsCallable.origin,
              'region': functions.region,
              'timeout': null,
              'parameters': kParameters,
            },
          ),
        ]);
      });

      test('invokes native method when options is null', () async {
        httpsCallable.options = null;

        await httpsCallable.call(kParameters);

        // check native method was called
        expect(logger, <Matcher>[
          isMethodCall(
            'FirebaseFunctions#call',
            arguments: <String, dynamic>{
              'appName': functions.app.name,
              'functionName': httpsCallable.name,
              'origin': httpsCallable.origin,
              'region': functions.region,
              'timeout': null,
              'parameters': kParameters,
            },
          ),
        ]);
      });

      test('accepts no args', () async {
        await httpsCallable.call();

        // check native method was called
        expect(logger, <Matcher>[
          isMethodCall(
            'FirebaseFunctions#call',
            arguments: <String, dynamic>{
              'appName': functions.app.name,
              'functionName': httpsCallable.name,
              'origin': httpsCallable.origin,
              'region': functions.region,
              'timeout': httpsCallable.timeout?.inMilliseconds,
              'parameters': null,
            },
          ),
        ]);
      });

      test('accepts null', () async {
        await httpsCallable.call();

        // check native method was called
        expect(logger, <Matcher>[
          isMethodCall(
            'FirebaseFunctions#call',
            arguments: <String, dynamic>{
              'appName': functions.app.name,
              'functionName': httpsCallable.name,
              'origin': httpsCallable.origin,
              'region': functions.region,
              'timeout': httpsCallable.timeout?.inMilliseconds,
              'parameters': null,
            },
          ),
        ]);
      });

      test('catch an [Exception] error', () async {
        mockExceptionThrown = true;

        Function callMethod = () => httpsCallable.call();
        await testExceptionHandling('EXCEPTION', callMethod);
      });

      test(
          'catch a [PlatformException] error and throws a [FirebaseStorageException] error',
          () async {
        mockPlatformExceptionThrown = true;

        Function callMethod = () => httpsCallable.call();
        await testExceptionHandling('PLATFORM', callMethod);
      });
    });
  });
}
