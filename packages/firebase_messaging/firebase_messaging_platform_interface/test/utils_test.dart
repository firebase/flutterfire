// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';
import 'package:firebase_messaging_platform_interface/src/utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Utilities', () {
    group('convertToAndroidNotificationPriority', () {
      test('returns correct AndroidNotificationPriority for priority value',
          () {
        expect(convertToAndroidNotificationPriority(-2),
            AndroidNotificationPriority.minimumPriority);
        expect(convertToAndroidNotificationPriority(-1),
            AndroidNotificationPriority.lowPriority);
        expect(convertToAndroidNotificationPriority(0),
            AndroidNotificationPriority.defaultPriority);
        expect(convertToAndroidNotificationPriority(1),
            AndroidNotificationPriority.highPriority);
        expect(convertToAndroidNotificationPriority(2),
            AndroidNotificationPriority.maximumPriority);
      });

      test(
          'returns AndroidNotificationPriority.defaultPriority '
          'if priority is not a possible value', () {
        expect(convertToAndroidNotificationPriority(-3),
            AndroidNotificationPriority.defaultPriority);
        expect(convertToAndroidNotificationPriority(3),
            AndroidNotificationPriority.defaultPriority);
      });

      test(
          'returns AndroidNotificationPriority.defaultPriority '
          'if priority is null', () {
        expect(convertToAndroidNotificationPriority(null),
            AndroidNotificationPriority.defaultPriority);
      });
    });

    group('convertAndroidNotificationPriorityToInt', () {
      test('returns correct priority value for AndroidNotificationPriority',
          () {
        expect(
            convertAndroidNotificationPriorityToInt(
                AndroidNotificationPriority.minimumPriority),
            -2);
        expect(
            convertAndroidNotificationPriorityToInt(
                AndroidNotificationPriority.lowPriority),
            -1);
        expect(
            convertAndroidNotificationPriorityToInt(
                AndroidNotificationPriority.defaultPriority),
            0);
        expect(
            convertAndroidNotificationPriorityToInt(
                AndroidNotificationPriority.highPriority),
            1);
        expect(
            convertAndroidNotificationPriorityToInt(
                AndroidNotificationPriority.maximumPriority),
            2);
      });

      test(
          'returns the priority value that represents '
          'AndroidNotificationPriority.defaultPriority '
          'if AndroidNotificationPriority is null', () {
        expect(convertAndroidNotificationPriorityToInt(null), 0);
      });
    });

    group('convertToAndroidNotificationVisibility', () {
      test('returns correct AndroidNotificationVisibility for visibility value',
          () {
        expect(convertToAndroidNotificationVisibility(-1),
            AndroidNotificationVisibility.secret);
        expect(convertToAndroidNotificationVisibility(0),
            AndroidNotificationVisibility.private);
        expect(convertToAndroidNotificationVisibility(1),
            AndroidNotificationVisibility.public);
      });

      test(
          'returns AndroidNotificationVisibility.private '
          'if visibility is no a possible value', () {
        expect(convertToAndroidNotificationVisibility(-2),
            AndroidNotificationVisibility.private);
        expect(convertToAndroidNotificationVisibility(2),
            AndroidNotificationVisibility.private);
      });

      test(
          'returns AndroidNotificationVisibility.private '
          'if visibility is null', () {
        expect(convertToAndroidNotificationVisibility(null),
            AndroidNotificationVisibility.private);
      });
    });

    group('convertAndroidNotificationVisibilityToInt', () {
      test('returns correct visibility value for AndroidNotificationVisibility',
          () {
        expect(
            convertAndroidNotificationVisibilityToInt(
                AndroidNotificationVisibility.secret),
            -1);
        expect(
            convertAndroidNotificationVisibilityToInt(
                AndroidNotificationVisibility.private),
            0);
        expect(
            convertAndroidNotificationVisibilityToInt(
                AndroidNotificationVisibility.public),
            1);
      });

      test(
          'returns the visibility value that represents '
          'AndroidNotificationVisibility.private '
          'if AndroidNotificationVisibility is null', () {
        expect(convertAndroidNotificationVisibilityToInt(null), 0);
      });
    });

    group('convertToAuthorizationStatus()', () {
      test('returns correct AuthorizationStatus for status value', () {
        expect(convertToAuthorizationStatus(-1),
            AuthorizationStatus.notDetermined);
        expect(convertToAuthorizationStatus(0), AuthorizationStatus.denied);
        expect(convertToAuthorizationStatus(1), AuthorizationStatus.authorized);
        expect(
            convertToAuthorizationStatus(2), AuthorizationStatus.provisional);
      });

      test(
          'returns AuthorizationStatus.notDetermined '
          'if status is no a possible value', () {
        expect(convertToAuthorizationStatus(-2),
            AuthorizationStatus.notDetermined);
        expect(
            convertToAuthorizationStatus(3), AuthorizationStatus.notDetermined);
      });

      test(
          'returns AuthorizationStatus.notDetermined '
          'if status is null', () {
        expect(convertToAuthorizationStatus(null),
            AuthorizationStatus.notDetermined);
      });
    });

    group('convertToAppleNotificationSetting', () {
      test('returns correct AppleNotificationSetting for status value', () {
        expect(convertToAppleNotificationSetting(-1),
            AppleNotificationSetting.notSupported);
        expect(convertToAppleNotificationSetting(0),
            AppleNotificationSetting.disabled);
        expect(convertToAppleNotificationSetting(1),
            AppleNotificationSetting.enabled);
      });

      test(
          'returns AppleNotificationSetting.notSupported '
          'if status is no a possible value', () {
        expect(convertToAppleNotificationSetting(-2),
            AppleNotificationSetting.notSupported);
        expect(convertToAppleNotificationSetting(2),
            AppleNotificationSetting.notSupported);
      });

      test(
          'returns AppleNotificationSetting.notSupported '
          'if status is null', () {
        expect(convertToAppleNotificationSetting(null),
            AppleNotificationSetting.notSupported);
      });
    });

    group('convertToAppleShowPreviewSetting', () {
      test('returns correct AppleShowPreviewSetting for status value', () {
        expect(convertToAppleShowPreviewSetting(-1),
            AppleShowPreviewSetting.notSupported);
        expect(
            convertToAppleShowPreviewSetting(0), AppleShowPreviewSetting.never);
        expect(convertToAppleShowPreviewSetting(1),
            AppleShowPreviewSetting.always);
        expect(convertToAppleShowPreviewSetting(2),
            AppleShowPreviewSetting.whenAuthenticated);
      });

      test(
          'returns AppleShowPreviewSetting.notSupported '
          'if status is no a possible value', () {
        expect(convertToAppleShowPreviewSetting(-2),
            AppleShowPreviewSetting.notSupported);
        expect(convertToAppleShowPreviewSetting(3),
            AppleShowPreviewSetting.notSupported);
      });

      test(
          'returns AppleShowPreviewSetting.notSupported '
          'if status is null', () {
        expect(convertToAppleShowPreviewSetting(null),
            AppleShowPreviewSetting.notSupported);
      });
    });
  });
}
