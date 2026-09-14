// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_in_app_messaging_platform_interface/src/method_channel/method_channel_firebase_in_app_messaging.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mock.dart';
import '../pigeon/test_api.dart';

void main() {
  setupFirebaseInAppMessagingMocks();

  late FirebaseApp app;
  late MethodChannelFirebaseInAppMessaging inAppMessaging;
  late _TestFirebaseInAppMessagingHostApi hostApi;

  setUpAll(() async {
    app = await Firebase.initializeApp();
    hostApi = _TestFirebaseInAppMessagingHostApi();
    TestFirebaseInAppMessagingHostApi.setUp(hostApi);
    inAppMessaging = MethodChannelFirebaseInAppMessaging(app: app);
  });

  tearDownAll(() {
    TestFirebaseInAppMessagingHostApi.setUp(null);
  });

  setUp(() {
    hostApi.reset();
  });

  test('triggerEvent forwards the app and event names', () async {
    await inAppMessaging.triggerEvent('campaign-event');

    expect(hostApi.appName, app.name);
    expect(hostApi.eventName, 'campaign-event');
  });

  test('setMessagesSuppressed forwards the app name and value', () async {
    await inAppMessaging.setMessagesSuppressed(true);

    expect(hostApi.appName, app.name);
    expect(hostApi.messagesSuppressed, isTrue);
  });

  test(
    'setAutomaticDataCollectionEnabled forwards the app name and value',
    () async {
      await inAppMessaging.setAutomaticDataCollectionEnabled(false);

      expect(hostApi.appName, app.name);
      expect(hostApi.automaticDataCollectionEnabled, isFalse);
    },
  );
}

class _TestFirebaseInAppMessagingHostApi
    implements TestFirebaseInAppMessagingHostApi {
  String? appName;
  String? eventName;
  bool? messagesSuppressed;
  bool? automaticDataCollectionEnabled;

  void reset() {
    appName = null;
    eventName = null;
    messagesSuppressed = null;
    automaticDataCollectionEnabled = null;
  }

  @override
  Future<void> triggerEvent(String appName, String eventName) async {
    this.appName = appName;
    this.eventName = eventName;
  }

  @override
  Future<void> setMessagesSuppressed(String appName, bool suppress) async {
    this.appName = appName;
    messagesSuppressed = suppress;
  }

  @override
  Future<void> setAutomaticDataCollectionEnabled(
    String appName,
    bool enabled,
  ) async {
    this.appName = appName;
    automaticDataCollectionEnabled = enabled;
  }
}
