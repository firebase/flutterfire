// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$MethodChannelFirebase', () {
    final MethodChannelFirebase channelPlatform = MethodChannelFirebase();
    final List<MethodCall> methodCallLog = <MethodCall>[];

    const FirebaseOptions testOptions = FirebaseOptions(
      apiKey: 'testing',
      appId: 'testing',
      messagingSenderId: 'testing',
      projectId: 'testing',
    );

    setUp(() async {
      MethodChannelFirebase.isCoreInitialized = false;
      MethodChannelFirebase.appInstances = {};

      MethodChannelFirebase.channel
          .setMockMethodCallHandler((MethodCall methodCall) async {
        methodCallLog.add(methodCall);

        switch (methodCall.method) {
          case 'Firebase#initializeCore':
            return [
              {
                'name': defaultFirebaseAppName,
                'options': <dynamic, dynamic>{
                  'apiKey': 'testAPIKey',
                  'appId': 'testBundleID',
                  'messagingSenderId': 'testClientID',
                  'projectId': 'testTrackingID',
                },
              }
            ];
          case 'Firebase#initializeApp':
            return <dynamic, dynamic>{
              'name': methodCall.arguments['appName'] ?? defaultFirebaseAppName,
              'options': <dynamic, dynamic>{
                'apiKey': 'testing',
                'appId': 'testing',
                'messagingSenderId': 'testing',
                'projectId': 'testing',
              },
            };
          default:
            return null;
        }
      });

      methodCallLog.clear();
    });

    group('.initializeApp()', () {
      test('should throw if trying to initialize default app', () async {
        await expectLater(
          () => channelPlatform.initializeApp(name: defaultFirebaseAppName),
          throwsA(noDefaultAppInitialization()),
        );
      });

      test('should initialize core if not first initialized', () async {
        await channelPlatform.initializeApp();

        expect(
          methodCallLog,
          <Matcher>[
            isMethodCall(
              'Firebase#initializeCore',
              arguments: null,
            ),
          ],
        );
      });

      test('should return the default app if no arguments passed', () async {
        FirebaseAppPlatform app = await channelPlatform.initializeApp();
        expect(app.name, defaultFirebaseAppName);
      });

      group('no default app', () {
        // Mock no default app being available
        setUp(() {
          MethodChannelFirebase.channel
              .setMockMethodCallHandler((MethodCall methodCall) async {
            methodCallLog.add(methodCall);

            switch (methodCall.method) {
              case 'Firebase#initializeCore':
                return [];
              default:
                return null;
            }
          });
        });

        test('should throw if no default app is available', () async {
          await expectLater(
            channelPlatform.initializeApp,
            throwsA(coreNotInitialized()),
          );
        });
      });

      group('secondary apps', () {
        test('should throw if no options are provided with a named app',
            () async {
          await expectLater(
            () => channelPlatform.initializeApp(name: 'foo'),
            throwsAssertionError,
          );
        });

        test('should initialize secondary apps', () async {
          await channelPlatform.initializeApp();
          await channelPlatform.initializeApp(
            name: 'foo',
            options: testOptions,
          );
          await channelPlatform.initializeApp(
            name: 'bar',
            options: testOptions,
          );

          expect(
            methodCallLog,
            <Matcher>[
              isMethodCall(
                'Firebase#initializeCore',
                arguments: null,
              ),
              isMethodCall(
                'Firebase#initializeApp',
                arguments: <String, dynamic>{
                  'appName': 'foo',
                  'options': testOptions.asMap,
                },
              ),
              isMethodCall(
                'Firebase#initializeApp',
                arguments: <String, dynamic>{
                  'appName': 'bar',
                  'options': testOptions.asMap,
                },
              ),
            ],
          );
        });
      });
    });

    group('.apps', () {
      test('should be empty before initialization', () async {
        List<FirebaseAppPlatform> apps = channelPlatform.apps;
        expect(apps.length, 0);
      });

      test('should return the default app when initialized', () async {
        await channelPlatform.initializeApp();
        List<FirebaseAppPlatform> apps = channelPlatform.apps;
        expect(apps.length, 1);
        expect(apps[0].name, defaultFirebaseAppName);
      });

      test('should remove a deleted app from the List', () async {
        FirebaseAppPlatform app = await channelPlatform.initializeApp(
          name: 'foo',
          options: testOptions,
        );

        // Default & foo
        expect(channelPlatform.apps.length, 2);

        await app.delete();
        expect(channelPlatform.apps.length, 1);
      });
    });

    group('.app()', () {
      test('should return the default app when no name provided', () async {
        await channelPlatform.initializeApp();
        FirebaseAppPlatform app = channelPlatform.app();
        expect(app.name, defaultFirebaseAppName);
      });

      test('should return a secondary app when a name is provided', () async {
        await channelPlatform.initializeApp(name: 'foo', options: testOptions);

        FirebaseAppPlatform app = channelPlatform.app('foo');
        expect(app.name, 'foo');
        expect(app.options, testOptions);
      });

      test('should throw if no named app was found', () {
        expect(
          () => channelPlatform.app('foo'),
          throwsA(noAppExists('foo')),
        );
      });
    });
  });
}
