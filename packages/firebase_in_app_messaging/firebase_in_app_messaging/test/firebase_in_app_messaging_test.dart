// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
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
      when(mockFiam.setCustomDisplayEnabled(any)).thenAnswer(
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

    test('onMessageClicked', () async {
      final controller = StreamController<InAppMessagingClickEvent>();
      addTearDown(controller.close);
      when(mockFiam.onMessageClicked).thenAnswer((_) => controller.stream);

      const event = InAppMessagingClickEvent(
        campaignMetadata: InAppMessagingCampaignMetadata(
          campaignId: 'campaign-id',
          campaignName: 'campaign-name',
          isTestMessage: false,
        ),
        action: InAppMessagingAction(actionUrl: 'https://example.com'),
      );

      final emitted = fiam.onMessageClicked.first;
      controller.add(event);

      expect(await emitted, event);
    });

    test('onMessageImpression', () async {
      final controller = StreamController<InAppMessagingImpressionEvent>();
      addTearDown(controller.close);
      when(mockFiam.onMessageImpression).thenAnswer((_) => controller.stream);

      const event = InAppMessagingImpressionEvent(
        campaignMetadata: InAppMessagingCampaignMetadata(
          campaignId: 'campaign-id',
          campaignName: 'campaign-name',
          isTestMessage: false,
        ),
      );

      final emitted = fiam.onMessageImpression.first;
      controller.add(event);

      expect(await emitted, event);
    });

    test('onMessageDismissed', () async {
      final controller = StreamController<InAppMessagingDismissEvent>();
      addTearDown(controller.close);
      when(mockFiam.onMessageDismissed).thenAnswer((_) => controller.stream);

      const event = InAppMessagingDismissEvent(
        campaignMetadata: InAppMessagingCampaignMetadata(
          campaignId: 'campaign-id',
          campaignName: 'campaign-name',
          isTestMessage: false,
        ),
        dismissType: InAppMessagingDismissType.swipe,
      );

      final emitted = fiam.onMessageDismissed.first;
      controller.add(event);

      expect(await emitted, event);
    });

    test('onMessageDisplayError', () async {
      final controller = StreamController<InAppMessagingDisplayErrorEvent>();
      addTearDown(controller.close);
      when(mockFiam.onMessageDisplayError).thenAnswer((_) => controller.stream);

      const event = InAppMessagingDisplayErrorEvent(
        campaignMetadata: InAppMessagingCampaignMetadata(
          campaignId: 'campaign-id',
          campaignName: 'campaign-name',
          isTestMessage: false,
        ),
        errorMessage: 'IMAGE_FETCH_ERROR',
      );

      final emitted = fiam.onMessageDisplayError.first;
      controller.add(event);

      expect(await emitted, event);
    });

    test('setCustomDisplayEnabled', () async {
      await fiam.setCustomDisplayEnabled(true);
      verify(mockFiam.setCustomDisplayEnabled(true));
    });

    test('onMessageDisplay', () async {
      final controller = StreamController<InAppMessage>();
      addTearDown(controller.close);
      when(mockFiam.onMessageDisplay).thenAnswer((_) => controller.stream);

      final event = InAppMessage(
        campaignMetadata: const InAppMessagingCampaignMetadata(
          campaignId: 'campaign-id',
          campaignName: 'campaign-name',
          isTestMessage: false,
        ),
        messageType: InAppMessageType.modal,
        onImpress: () async {},
        onClick: (_) async {},
        onDismiss: (_) async {},
        onError: (_) async {},
      );

      final emitted = fiam.onMessageDisplay.first;
      controller.add(event);

      expect(await emitted, event);
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

  @override
  Stream<InAppMessagingClickEvent> get onMessageClicked {
    return super.noSuchMethod(
      Invocation.getter(#onMessageClicked),
      returnValue: const Stream<InAppMessagingClickEvent>.empty(),
      returnValueForMissingStub: const Stream<InAppMessagingClickEvent>.empty(),
    );
  }

  @override
  Stream<InAppMessagingImpressionEvent> get onMessageImpression {
    return super.noSuchMethod(
      Invocation.getter(#onMessageImpression),
      returnValue: const Stream<InAppMessagingImpressionEvent>.empty(),
      returnValueForMissingStub:
          const Stream<InAppMessagingImpressionEvent>.empty(),
    );
  }

  @override
  Stream<InAppMessagingDismissEvent> get onMessageDismissed {
    return super.noSuchMethod(
      Invocation.getter(#onMessageDismissed),
      returnValue: const Stream<InAppMessagingDismissEvent>.empty(),
      returnValueForMissingStub:
          const Stream<InAppMessagingDismissEvent>.empty(),
    );
  }

  @override
  Stream<InAppMessagingDisplayErrorEvent> get onMessageDisplayError {
    return super.noSuchMethod(
      Invocation.getter(#onMessageDisplayError),
      returnValue: const Stream<InAppMessagingDisplayErrorEvent>.empty(),
      returnValueForMissingStub:
          const Stream<InAppMessagingDisplayErrorEvent>.empty(),
    );
  }

  @override
  Future<void> setCustomDisplayEnabled(bool? enabled) {
    return super.noSuchMethod(
      Invocation.method(#setCustomDisplayEnabled, [enabled]),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value(),
    );
  }

  @override
  Stream<InAppMessage> get onMessageDisplay {
    return super.noSuchMethod(
      Invocation.getter(#onMessageDisplay),
      returnValue: const Stream<InAppMessage>.empty(),
      returnValueForMissingStub: const Stream<InAppMessage>.empty(),
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
