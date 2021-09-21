// ignore_for_file: require_trailing_commas
// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics_platform_interface/src/platform_interface/platform_interface_firebase_analytics.dart';
import 'package:firebase_analytics_platform_interface/src/method_channel/method_channel_firebase_analytics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FirebaseApp app;
  group('$FirebaseAnalyticsPlatform', () {
    test('$MethodChannelFirebaseAnalytics is the default instance', () {
      expect(FirebaseAnalyticsPlatform.instance,
          isA<MethodChannelFirebaseAnalytics>());
    });

    test('Cannot be implemented with `implements`', () {
      expect(() {
        FirebaseAnalyticsPlatform.instance =
            ImplementsFirebaseAnalyticsPlatform(false);
      }, throwsAssertionError);
    });

    test('Can be extended', () async {
      app = await Firebase.initializeApp();
      FirebaseAnalyticsPlatform.instance = ExtendsFirebaseAnalyticsPlatform(app);
    });

    test('Can be mocked with `implements`', () {
      final ImplementsFirebaseAnalyticsPlatform mock =
          ImplementsFirebaseAnalyticsPlatform(true);
      FirebaseAnalyticsPlatform.instance = mock;
    });
  });
}

class Mock {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class ImplementsFirebaseAnalyticsPlatform extends Mock
    implements FirebaseAnalyticsPlatform {
  ImplementsFirebaseAnalyticsPlatform(this._isMock);

  bool _isMock;

  @override
  bool get isMock => _isMock;
}

class ExtendsFirebaseAnalyticsPlatform extends FirebaseAnalyticsPlatform {
  ExtendsFirebaseAnalyticsPlatform(app) : super(app);
}
