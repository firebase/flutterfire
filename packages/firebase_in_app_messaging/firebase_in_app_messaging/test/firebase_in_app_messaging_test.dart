// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:firebase_in_app_messaging_platform_interface/firebase_in_app_messaging_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

typedef Callback = Function(MethodCall call);

MockFirebaseInAppMessaging mockFiam = MockFirebaseInAppMessaging();

void main() {
  setupFirebaseIAMMocks();

  late FirebaseInAppMessaging fiam;
  FirebaseInAppMessagingPlatform.instance = mockFiam;
  group('$FirebaseInAppMessaging', () {
    setUpAll(() async {
      await Firebase.initializeApp();

      fiam = FirebaseInAppMessaging.instance;
      when(
        mockFiam.delegateFor(
          app: anyNamed('app'),
        ),
      ).thenAnswer(
        (_) => mockFiam,
      );
      when(mockFiam.triggerEvent('someEvent')).thenAnswer(
        (_) => Future<void>.value(),
      );
      when(mockFiam.setMessagesSuppressed(any)).thenAnswer(
        (_) => Future<void>.value(),
      );
      when(mockFiam.setAutomaticDataCollectionEnabled(any)).thenAnswer(
        (_) => Future<void>.value(),
      );
    });

    test('triggerEvent', () async {
      await fiam.triggerEvent('someEvent');
      verify(mockFiam.triggerEvent('someEvent'));
    });

    test('setMessagesSuppressed', () async {
      await fiam.setMessagesSuppressed(true);
      verify(mockFiam.setMessagesSuppressed(true));

      await fiam.setMessagesSuppressed(false);
      verify(mockFiam.setMessagesSuppressed(false));
    });

    test('setDataCollectionEnabled', () async {
      await fiam.setAutomaticDataCollectionEnabled(true);
      verify(mockFiam.setAutomaticDataCollectionEnabled(true));

      await fiam.setAutomaticDataCollectionEnabled(false);
      verify(mockFiam.setAutomaticDataCollectionEnabled(false));
    });
  });
}

void setupFirebaseIAMMocks([Callback? customHandlers]) {
  TestWidgetsFlutterBinding.ensureInitialized();

  setupFirebaseCoreMocks();
}

class MockFirebaseInAppMessaging extends Mock
    with
        // ignore: prefer_mixin
        MockPlatformInterfaceMixin
    implements
        TestFirebaseInAppMessagingPlatform {
  @override
  FirebaseInAppMessagingPlatform delegateFor({FirebaseApp? app}) {
    return super.noSuchMethod(
      Invocation.method(#delegateFor, [], {#app: app}),
      returnValue: TestFirebaseInAppMessagingPlatform(app),
      returnValueForMissingStub: TestFirebaseInAppMessagingPlatform(app),
    );
  }

  @override
  Future<void> setAutomaticDataCollectionEnabled(bool? enabled) {
    return super.noSuchMethod(
      Invocation.method(#setAutomaticDataCollectionEnabled, [enabled]),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value(),
    );
  }

  @override
  Future<void> setMessagesSuppressed(bool? suppress) {
    return super.noSuchMethod(
      Invocation.method(#setMessagesSuppressed, [suppress]),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value(),
    );
  }

  @override
  Future<void> triggerEvent(String? eventName) {
    return super.noSuchMethod(
      Invocation.method(#triggerEvent, [eventName]),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value(),
    );
  }
}

class TestFirebaseInAppMessagingPlatform
    extends FirebaseInAppMessagingPlatform {
  TestFirebaseInAppMessagingPlatform(FirebaseApp? app) : super(app);

  @override
  FirebaseInAppMessagingPlatform delegateFor({FirebaseApp? app}) {
    return this;
  }
}
