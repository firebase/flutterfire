// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:firebase_crashlytics_platform_interface/test.dart';
import 'package:flutter_test/flutter_test.dart';

final FakeFirebaseCrashlyticsHostApi hostApi = FakeFirebaseCrashlyticsHostApi();

class MockFirebaseAppWithCollectionEnabled implements TestFirebaseCoreHostApi {
  @override
  Future<CoreInitializeResponse> initializeApp(
    String appName,
    CoreFirebaseOptions initializeAppRequest,
  ) async {
    return CoreInitializeResponse(
      name: appName,
      options: CoreFirebaseOptions(
        apiKey: '123',
        projectId: '123',
        appId: '123',
        messagingSenderId: '123',
      ),
      pluginConstants: {
        'plugins.flutter.io/firebase_crashlytics': {
          'isCrashlyticsCollectionEnabled': true
        }
      },
    );
  }

  @override
  Future<List<CoreInitializeResponse>> initializeCore() async {
    return [
      CoreInitializeResponse(
        name: defaultFirebaseAppName,
        options: CoreFirebaseOptions(
          apiKey: '123',
          projectId: '123',
          appId: '123',
          messagingSenderId: '123',
        ),
        pluginConstants: {
          'plugins.flutter.io/firebase_crashlytics': {
            'isCrashlyticsCollectionEnabled': true
          }
        },
      )
    ];
  }

  @override
  Future<CoreFirebaseOptions> optionsFromResource() async {
    return CoreFirebaseOptions(
      apiKey: '123',
      projectId: '123',
      appId: '123',
      messagingSenderId: '123',
    );
  }
}

void setupFirebaseCrashlyticsMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();

  TestFirebaseCoreHostApi.setUp(MockFirebaseAppWithCollectionEnabled());
  TestFirebaseCrashlyticsHostApi.setUp(hostApi);
}

class FakeFirebaseCrashlyticsHostApi implements TestFirebaseCrashlyticsHostApi {
  final List<String> calls = <String>[];
  RecordErrorRequest? lastRecordError;
  String? lastLogMessage;
  bool? lastCollectionEnabled;
  String? lastUserIdentifier;
  String? lastCustomKey;
  String? lastCustomValue;

  void reset() {
    calls.clear();
    lastRecordError = null;
    lastLogMessage = null;
    lastCollectionEnabled = null;
    lastUserIdentifier = null;
    lastCustomKey = null;
    lastCustomValue = null;
  }

  @override
  Future<bool> checkForUnsentReports() async {
    calls.add('checkForUnsentReports');
    return true;
  }

  @override
  Future<void> crash() async {
    calls.add('crash');
  }

  @override
  Future<void> deleteUnsentReports() async {
    calls.add('deleteUnsentReports');
  }

  @override
  Future<bool> didCrashOnPreviousExecution() async {
    calls.add('didCrashOnPreviousExecution');
    return true;
  }

  @override
  Future<void> recordError(RecordErrorRequest request) async {
    calls.add('recordError');
    lastRecordError = request;
  }

  @override
  Future<void> log(String message) async {
    calls.add('log');
    lastLogMessage = message;
  }

  @override
  Future<void> sendUnsentReports() async {
    calls.add('sendUnsentReports');
  }

  @override
  Future<bool> setCrashlyticsCollectionEnabled(bool enabled) async {
    calls.add('setCrashlyticsCollectionEnabled');
    lastCollectionEnabled = enabled;
    return enabled;
  }

  @override
  Future<void> setUserIdentifier(String identifier) async {
    calls.add('setUserIdentifier');
    lastUserIdentifier = identifier;
  }

  @override
  Future<void> setCustomKey(String key, String value) async {
    calls.add('setCustomKey');
    lastCustomKey = key;
    lastCustomValue = value;
  }
}
