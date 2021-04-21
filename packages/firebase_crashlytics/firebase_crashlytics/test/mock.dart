// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_crashlytics_platform_interface/firebase_crashlytics_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

typedef Callback = void Function(MethodCall call);

final List<MethodCall> methodCallLog = <MethodCall>[];

void setupFirebaseCrashlyticsMocks([Callback? customHandlers]) {
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
          'pluginConstants': {
            'plugins.flutter.io/firebase_crashlytics': {
              'isCrashlyticsCollectionEnabled': true
            }
          },
        }
      ];
    }

    if (call.method == 'Firebase#initializeApp') {
      return {
        'name': call.arguments['appName'],
        'options': call.arguments['options'],
        'pluginConstants': {
          'plugins.flutter.io/firebase_crashlytics': {
            'isCrashlyticsCollectionEnabled': true
          }
        },
      };
    }

    if (customHandlers != null) {
      customHandlers(call);
    }

    return null;
  });

  MethodChannelFirebaseCrashlytics.channel
      .setMockMethodCallHandler((MethodCall methodCall) async {
    methodCallLog.add(methodCall);
    switch (methodCall.method) {
      case 'Crashlytics#checkForUnsentReports':
        return {
          'unsentReports': true,
        };
      case 'Crashlytics#setCrashlyticsCollectionEnabled':
        return {
          'isCrashlyticsCollectionEnabled': methodCall.arguments['enabled']
        };
      case 'Crashlytics#didCrashOnPreviousExecution':
        return {
          'didCrashOnPreviousExecution': true,
        };
      case 'Crashlytics#recordError':
        return null;
      default:
        return false;
    }
  });
}
