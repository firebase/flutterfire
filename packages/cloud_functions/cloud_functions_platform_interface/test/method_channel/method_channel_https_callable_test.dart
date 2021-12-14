// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_functions_platform_interface/cloud_functions_platform_interface.dart';
import 'package:cloud_functions_platform_interface/src/method_channel/method_channel_firebase_functions.dart';
import 'package:cloud_functions_platform_interface/src/method_channel/method_channel_https_callable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import '../mock.dart';

void main() {
  setupFirebaseFunctionsMocks();

  MethodChannelFirebaseFunctions? functions;
  MethodChannelHttpsCallable? httpsCallable;
  final List<MethodCall> logger = <MethodCall>[];

  // mock props
  bool mockPlatformExceptionThrown = false;
  bool mockExceptionThrown = false;
  String kName = 'test_name';
  String kOrigin = 'test_origin';
  dynamic kParameters = {'foo': 'bar'};
  HttpsCallableOptions kOptions = HttpsCallableOptions();
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

      functions =
          MethodChannelFirebaseFunctions(app: app, region: 'us-central1');
      httpsCallable = MethodChannelHttpsCallable(
        functions!,
        kOrigin,
        kName,
        kOptions,
      );
    });

    setUp(() async {
      mockPlatformExceptionThrown = false;
      mockExceptionThrown = false;
      httpsCallable!.options = kOptions;

      logger.clear();
    });

    group('constructor', () {
      test('should create an instance', () {
        expect(httpsCallable, isInstanceOf<MethodChannelHttpsCallable>());
        expect(httpsCallable, isInstanceOf<HttpsCallablePlatform>());
      });

      test('should set name', () {
        expect(httpsCallable!.name, isInstanceOf<String>());
        expect(httpsCallable!.name, kName);
      });

      test('should set origin', () {
        expect(httpsCallable!.origin, isInstanceOf<String>());
        expect(httpsCallable!.origin, kOrigin);
      });

      test('should set options', () {
        expect(httpsCallable!.options, isInstanceOf<HttpsCallableOptions>());
        expect(httpsCallable!.options.timeout, isInstanceOf<Duration>());
        expect(httpsCallable!.options.timeout.inMinutes, 1);
      });
    });

    group('options', () {
      test('should set options', () {
        expect(httpsCallable!.options, isInstanceOf<HttpsCallableOptions>());
        expect(httpsCallable!.options.timeout, isInstanceOf<Duration>());
        expect(httpsCallable!.options.timeout.inMinutes, 1);
      });
    });

    group('call', () {
      test('invokes native method with correct args', () async {
        final result = await httpsCallable!.call(kParameters);

        expect(result, isA<dynamic>());
        expect(result['foo'], 'bar');

        // check native method was called
        expect(logger, <Matcher>[
          isMethodCall(
            'FirebaseFunctions#call',
            arguments: <String, dynamic>{
              'appName': functions!.app!.name,
              'functionName': httpsCallable!.name,
              'origin': httpsCallable!.origin,
              'region': functions!.region,
              'timeout': httpsCallable!.options.timeout.inMilliseconds,
              'parameters': kParameters,
            },
          ),
        ]);
      });

      test('accepts no args', () async {
        await httpsCallable!.call();

        // check native method was called
        expect(logger, <Matcher>[
          isMethodCall(
            'FirebaseFunctions#call',
            arguments: <String, dynamic>{
              'appName': functions!.app!.name,
              'functionName': httpsCallable!.name,
              'origin': httpsCallable!.origin,
              'region': functions!.region,
              'timeout': httpsCallable!.options.timeout.inMilliseconds,
              'parameters': null,
            },
          ),
        ]);
      });

      test('accepts null', () async {
        await httpsCallable!.call();

        // check native method was called
        expect(logger, <Matcher>[
          isMethodCall(
            'FirebaseFunctions#call',
            arguments: <String, dynamic>{
              'appName': functions!.app!.name,
              'functionName': httpsCallable!.name,
              'origin': httpsCallable!.origin,
              'region': functions!.region,
              'timeout': httpsCallable!.options.timeout.inMilliseconds,
              'parameters': null,
            },
          ),
        ]);
      });

      test('catch an [Exception] error', () async {
        mockExceptionThrown = true;
        await testExceptionHandling('EXCEPTION', httpsCallable!.call);
      });

      test(
          'catch a [PlatformException] error and throws a [FirebaseStorageException] error',
          () async {
        mockPlatformExceptionThrown = true;
        await testExceptionHandling('PLATFORM', httpsCallable!.call);
      });
    });
  });
}
