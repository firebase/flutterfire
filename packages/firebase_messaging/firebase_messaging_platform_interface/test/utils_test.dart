// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';
import 'package:firebase_messaging_platform_interface/src/utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Utilities', () {
    test('convertToNotificationPriority()', () {
      expect(convertToNotificationPriority(1), isA<NotificationPriority>());
    });

    test('convertFromNotificationPriority()', () {
      expect(convertFromNotificationPriority(NotificationPriority.high),
          isA<int>());
    });

    test('convertToNotificationVisibility()', () {
      expect(convertToNotificationVisibility(1), isA<NotificationVisibility>());
    });

    test('convertFromNotificationVisibility()', () {
      expect(convertFromNotificationVisibility(NotificationVisibility.public),
          isA<int>());
    });

    test('convertToAuthorizationStatus()', () {
      expect(convertToAuthorizationStatus(1), isA<AuthorizationStatus>());
    });
  });
}
