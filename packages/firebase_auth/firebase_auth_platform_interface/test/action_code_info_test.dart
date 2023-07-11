// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const kMockOperation = ActionCodeInfoOperation.verifyEmail;
  const String kMockEmail = 'test@test.com';
  const String kMockPreviousEmail = 'previous@test.com';
  final kMockData =
      ActionCodeInfoData(email: kMockEmail, previousEmail: kMockPreviousEmail);

  group('$ActionCodeInfo', () {
    ActionCodeInfo actionCodeInfo =
        ActionCodeInfo(operation: kMockOperation, data: kMockData);
    group('Constructor', () {
      test('returns an instance of [ActionCodeInfo]', () {
        expect(actionCodeInfo, isA<ActionCodeInfo>());
      });
    });

    group('data', () {
      test('returns expected data', () {
        expect(actionCodeInfo.data, isA<Map<String, dynamic>>());
        expect(actionCodeInfo.data['email'], equals(kMockEmail));
        expect(
            actionCodeInfo.data['previousEmail'], equals(kMockPreviousEmail));
      });

      test('handles email is null', () {
        ActionCodeInfo testActionCodeInfo = ActionCodeInfo(
            operation: kMockOperation,
            data: ActionCodeInfoData(
              email: null,
              previousEmail: kMockPreviousEmail,
            ));
        expect(testActionCodeInfo.data, isA<Map<String, dynamic>>());
        expect(testActionCodeInfo.data['email'], isNull);
        expect(testActionCodeInfo.data['previousEmail'],
            equals(kMockPreviousEmail));
      });

      test('handles previousEmail is null', () {
        ActionCodeInfo testActionCodeInfo = ActionCodeInfo(
            operation: kMockOperation,
            data: ActionCodeInfoData(
              email: kMockEmail,
              previousEmail: null,
            ));
        expect(testActionCodeInfo.data, isA<Map<String, dynamic>>());
        expect(testActionCodeInfo.data['email'], equals(kMockEmail));
        expect(testActionCodeInfo.data['previousEmail'], isNull);
      });
    });

    group('operation', () {
      test('returns an instance of [ActionCodeInfoOperation]', () {
        expect(actionCodeInfo.operation, isA<ActionCodeInfoOperation>());
        expect(actionCodeInfo.operation,
            equals(ActionCodeInfoOperation.verifyEmail));
      });

      test('returns operation type `emailSignIn`', () {
        ActionCodeInfo testActionCodeInfo = ActionCodeInfo(
            operation: ActionCodeInfoOperation.emailSignIn, data: kMockData);

        expect(testActionCodeInfo.operation, isA<ActionCodeInfoOperation>());
        expect(testActionCodeInfo.operation,
            equals(ActionCodeInfoOperation.emailSignIn));
      });

      test('returns operation type `passwordReset`', () {
        ActionCodeInfo testActionCodeInfo = ActionCodeInfo(
            operation: ActionCodeInfoOperation.passwordReset, data: kMockData);

        expect(testActionCodeInfo.operation, isA<ActionCodeInfoOperation>());
        expect(testActionCodeInfo.operation,
            equals(ActionCodeInfoOperation.passwordReset));
      });

      test('returns operation type `recoverEmail`', () {
        ActionCodeInfo testActionCodeInfo = ActionCodeInfo(
            operation: ActionCodeInfoOperation.recoverEmail, data: kMockData);

        expect(testActionCodeInfo.operation, isA<ActionCodeInfoOperation>());
        expect(testActionCodeInfo.operation,
            equals(ActionCodeInfoOperation.recoverEmail));
      });

      test('returns operation type `verifyAndChangeEmail`', () {
        ActionCodeInfo testActionCodeInfo = ActionCodeInfo(
            operation: ActionCodeInfoOperation.verifyAndChangeEmail,
            data: kMockData);

        expect(testActionCodeInfo.operation, isA<ActionCodeInfoOperation>());
        expect(testActionCodeInfo.operation,
            equals(ActionCodeInfoOperation.verifyAndChangeEmail));
      });

      test('returns operation type `verifyEmail`', () {
        ActionCodeInfo testActionCodeInfo = ActionCodeInfo(
            operation: ActionCodeInfoOperation.verifyEmail, data: kMockData);

        expect(testActionCodeInfo.operation, isA<ActionCodeInfoOperation>());
        expect(testActionCodeInfo.operation,
            equals(ActionCodeInfoOperation.verifyEmail));
      });
    });
  });
}
