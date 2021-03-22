// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart=2.9

import 'package:firebase_analytics_platform_interface/firebase_analytics_platform_interface.dart';
import 'package:firebase_analytics_platform_interface/method_channel_firebase_analytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('$FirebaseAnalyticsPlatform', () {
    test('$MethodChannelFirebaseAnalytics is the default instance', () {
      expect(FirebaseAnalyticsPlatform.instance,
          isA<MethodChannelFirebaseAnalytics>());
    });

    test('Cannot be implemented with `implements`', () {
      expect(() {
        FirebaseAnalyticsPlatform.instance =
            ImplementsFirebaseAnalyticsPlatform();
      }, throwsAssertionError);
    });

    test('Can be extended', () {
      FirebaseAnalyticsPlatform.instance = ExtendsFirebaseAnalyticsPlatform();
    });

    test('Can be mocked with `implements`', () {
      final ImplementsFirebaseAnalyticsPlatform mock =
          ImplementsFirebaseAnalyticsPlatform();
      when(mock.isMock).thenReturn(true);
      FirebaseAnalyticsPlatform.instance = mock;
    });
  });
}

class ImplementsFirebaseAnalyticsPlatform extends Mock
    implements FirebaseAnalyticsPlatform {}

class ExtendsFirebaseAnalyticsPlatform extends FirebaseAnalyticsPlatform {}
