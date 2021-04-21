// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$MethodChannelFirebaseApp', () {
    final List<MethodCall> methodCallLog = <MethodCall>[];

    const FirebaseOptions testOptions = FirebaseOptions(
      apiKey: 'testing',
      appId: 'testing',
      messagingSenderId: 'testing',
      projectId: 'testing',
    );

    final MethodChannelFirebaseApp methodChannelFirebaseApp =
        MethodChannelFirebaseApp('foo', testOptions);

    setUp(() async {
      MethodChannelFirebase.channel
          .setMockMethodCallHandler((MethodCall methodCall) async {
        methodCallLog.add(methodCall);

        switch (methodCall.method) {
          case 'FirebaseApp#delete':
          case 'FirebaseApp#setAutomaticDataCollectionEnabled':
          case 'FirebaseApp#setAutomaticResourceManagementEnabled':
            return null;
          default:
            throw FallThroughError();
        }
      });

      methodCallLog.clear();
    });

    test('should return the name', () {
      expect(methodChannelFirebaseApp.name, 'foo');
    });

    test('should return the options', () {
      expect(methodChannelFirebaseApp.options, testOptions);
    });

    group('setAutomaticDataCollectionEnabled()', () {
      test('should update the local instance property', () async {
        expect(
            methodChannelFirebaseApp.isAutomaticDataCollectionEnabled, false);

        await methodChannelFirebaseApp.setAutomaticDataCollectionEnabled(true);

        expect(
          methodCallLog,
          <Matcher>[
            isMethodCall(
              'FirebaseApp#setAutomaticDataCollectionEnabled',
              arguments: <String, dynamic>{
                'appName': 'foo',
                'enabled': true,
              },
            ),
          ],
        );

        expect(methodChannelFirebaseApp.isAutomaticDataCollectionEnabled, true);
      });
    });

    group('setAutomaticResourceManagementEnabled()', () {
      test('should call the method channel', () async {
        await methodChannelFirebaseApp
            .setAutomaticResourceManagementEnabled(true);

        expect(
          methodCallLog,
          <Matcher>[
            isMethodCall(
              'FirebaseApp#setAutomaticResourceManagementEnabled',
              arguments: <String, dynamic>{
                'appName': 'foo',
                'enabled': true,
              },
            ),
          ],
        );
      });
    });

    group('delete()', () {
      test('should throw if deleting the default', () async {
        final MethodChannelFirebaseApp defaultApp =
            MethodChannelFirebaseApp(defaultFirebaseAppName, testOptions);

        try {
          await defaultApp.delete();
        } on FirebaseException catch (e) {
          expect(e, noDefaultAppDelete());
          return;
        }

        fail('FirebaseException not thrown');
      });

      test('should resolve if _isDeleted is true', () async {
        await methodChannelFirebaseApp.delete();
        await methodChannelFirebaseApp.delete();

        // Should only be one call if already deleted
        expect(
          methodCallLog,
          <Matcher>[
            isMethodCall(
              'FirebaseApp#delete',
              arguments: <String, dynamic>{
                'appName': 'foo',
                'options': testOptions.asMap,
              },
            ),
          ],
        );
      });
    });
  });
}
