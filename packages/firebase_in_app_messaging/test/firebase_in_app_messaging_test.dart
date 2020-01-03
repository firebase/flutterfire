// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$FirebaseInAppMessaging', () {
    final List<MethodCall> log = <MethodCall>[];

    setUp(() {
      log.clear();
      FirebaseInAppMessaging.channel
          .setMockMethodCallHandler((MethodCall methodcall) async {
        log.add(methodcall);
        return true;
      });
    });

    test('triggerEvent', () async {
      final FirebaseInAppMessaging fiam = FirebaseInAppMessaging();
      await fiam.triggerEvent('someEvent');
      expect(log, <Matcher>[
        isMethodCall('triggerEvent',
            arguments: <String, String>{'eventName': 'someEvent'}),
      ]);
    });

    test('setMessagesSuppressed', () async {
      final FirebaseInAppMessaging fiam = FirebaseInAppMessaging();
      await fiam.setMessagesSuppressed(true);
      expect(log,
          <Matcher>[isMethodCall('setMessagesSuppressed', arguments: true)]);

      log.clear();
      fiam.setMessagesSuppressed(false);
      expect(log, <Matcher>[
        isMethodCall('setMessagesSuppressed', arguments: false),
      ]);
    });

    test('setDataCollectionEnabled', () async {
      final FirebaseInAppMessaging fiam = FirebaseInAppMessaging();
      await fiam.setAutomaticDataCollectionEnabled(true);
      expect(log, <Matcher>[
        isMethodCall('setAutomaticDataCollectionEnabled', arguments: true)
      ]);

      log.clear();
      fiam.setAutomaticDataCollectionEnabled(false);
      expect(log, <Matcher>[
        isMethodCall('setAutomaticDataCollectionEnabled', arguments: false),
      ]);
    });

    test('configure', () async {
      final Completer<dynamic> onImpression = Completer<dynamic>();
      final Completer<dynamic> onClicked = Completer<dynamic>();
      final Completer<dynamic> onError = Completer<dynamic>();
      final FirebaseInAppMessaging fiam = FirebaseInAppMessaging();

      fiam.configure(onImpression: (dynamic m) async {
        onImpression.complete(m);
      }, onClicked: (dynamic m) async {
        onClicked.complete(m);
      }, onError: (dynamic m) async {
        onError.complete(m);
      });
      FirebaseInAppMessaging.channel
          .setMockMethodCallHandler(fiam.handleMethod);

      final Map<String, dynamic> onImpressionMessage = <String, dynamic>{
        'messageID': '1111',
        'campaignName': 'test'
      };
      final Map<String, dynamic> onClickedMessage = <String, dynamic>{
        'messageID': '1111',
        'campaignName': 'test',
        'action': {'actionText': 'testAction', 'actionURL': 'actionURL'}
      };
      final Map<String, dynamic> onErrorMessage = <String, dynamic>{
        'code': 'codeText',
        'message': null,
        'details': 'detailText'
      };
      await FirebaseInAppMessaging.channel
          .invokeMethod<void>('onImpression', onImpressionMessage);
      final InAppMessageData onImpressionData = await onImpression.future;
      expect(
          hashValues(onImpressionData.messageID, onImpressionData.campaignName),
          hashValues('1111', 'test'));
      expect(onClicked.isCompleted, isFalse);
      expect(onError.isCompleted, isFalse);

      await FirebaseInAppMessaging.channel
          .invokeMethod('onClicked', onClickedMessage);
      final InAppMessageData onClickedData = await onClicked.future;
      expect(
          hashValues(onClickedData.messageID, onClickedData.campaignName,
              onClickedData.action.actionText, onClickedData.action.actionURL),
          hashValues('1111', 'test', 'testAction', 'actionURL'));
      expect(onError.isCompleted, isFalse);

      await FirebaseInAppMessaging.channel
          .invokeMethod('onError', onErrorMessage);
      final InAppMessageErrorException exception = await onError.future;
      expect(exception.toString(),
          'PlatformException(codeText, null, detailText)');
    });
  });
}
