// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_functions_platform_interface/cloud_functions_platform_interface.dart';
import 'package:cloud_functions_platform_interface/src/method_channel/method_channel_firebase_functions.dart';
import 'package:cloud_functions_platform_interface/src/method_channel/method_channel_https_callable.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mock.dart';
import '../pigeon/test_api.dart';

void main() {
  setupFirebaseFunctionsMocks();

  MethodChannelFirebaseFunctions? functions;
  MethodChannelHttpsCallable? httpsCallable;

  // mock props
  bool mockPlatformExceptionThrown = false;
  bool mockExceptionThrown = false;
  String kName = 'test_name';
  String kOrigin = 'test_origin';
  dynamic kParameters = {'foo': 'bar'};
  HttpsCallableOptions kOptions = HttpsCallableOptions();
  String kPlatformExceptionMessage = 'Mock platform exception thrown';
  Map<String, Object?>? lastCallArguments;

  group('$MethodChannelHttpsCallable', () {
    setUpAll(() async {
      FirebaseApp app = await Firebase.initializeApp();

      TestCloudFunctionsHostApi.setUp(
          _TestCloudFunctionsHostApi((arguments) async {
        lastCallArguments = arguments;
        if (mockExceptionThrown) {
          throw Exception();
        } else if (mockPlatformExceptionThrown) {
          throw PlatformException(
              code: 'UNKNOWN', message: kPlatformExceptionMessage);
        }
        return kParameters;
      }));

      functions =
          MethodChannelFirebaseFunctions(app: app, region: 'us-central1');
      httpsCallable = MethodChannelHttpsCallable(
        functions!,
        kOrigin,
        kName,
        kOptions,
        null,
      );
    });

    setUp(() async {
      mockPlatformExceptionThrown = false;
      mockExceptionThrown = false;
      lastCallArguments = null;
      functions!.allowInsecureTokenAttachment = false;
      httpsCallable!.options = kOptions;
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
        expect(httpsCallable!.options.limitedUseAppCheckToken, false);
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
      test('sends allowInsecureTokenAttachment, defaulting to false', () async {
        await httpsCallable!.call();

        expect(lastCallArguments?['allowInsecureTokenAttachment'], isFalse);

        functions!.allowInsecureTokenAttachment = true;
        await httpsCallable!.call();

        expect(lastCallArguments?['allowInsecureTokenAttachment'], isTrue);
      });

      test('converts maps nested in lists', () async {
        final originalParameters = kParameters;
        addTearDown(() => kParameters = originalParameters);
        kParameters = <Object?>[
          <Object?, Object?>{'name': 'value'},
        ];

        final result = await httpsCallable!.call();

        expect(result, isA<List<dynamic>>());
        expect((result as List<dynamic>).single, isA<Map<String, dynamic>>());
        expect(result, <dynamic>[
          <String, dynamic>{'name': 'value'},
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

    group('stream', () {
      test('sends allowInsecureTokenAttachment on the event channel', () async {
        functions!.allowInsecureTokenAttachment = true;
        const channelName = 'plugins.flutter.io/firebase_functions/test_name_0';
        Object? listenedArguments;
        final messenger =
            TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
        messenger.setMockMethodCallHandler(const MethodChannel(channelName),
            (call) async {
          if (call.method == 'listen') {
            listenedArguments = call.arguments;
          }
          return null;
        });
        addTearDown(() {
          messenger.setMockMethodCallHandler(
              const MethodChannel(channelName), null);
        });

        final subscription = httpsCallable!.stream(null).listen((_) {});
        await Future<void>.delayed(Duration.zero);
        await subscription.cancel();

        expect(listenedArguments, isA<Map>());
        expect(
          (listenedArguments! as Map)['allowInsecureTokenAttachment'],
          isTrue,
        );
      });
    });
  });
}

class _TestCloudFunctionsHostApi implements TestCloudFunctionsHostApi {
  _TestCloudFunctionsHostApi(this.callHandler);

  final Future<Object?> Function(Map<String, Object?> arguments) callHandler;

  @override
  Future<Object?> call(Map<String, Object?> arguments) =>
      callHandler(arguments);

  @override
  Future<void> registerEventChannel(Map<String, Object> arguments) async {}
}
