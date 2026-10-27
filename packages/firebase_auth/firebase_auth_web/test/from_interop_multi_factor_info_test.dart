// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('browser')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_auth_web/src/interop/auth_interop.dart'
    as auth_interop;
import 'package:firebase_auth_web/src/interop/multi_factor.dart'
    as multi_factor_interop;
import 'package:firebase_auth_web/src/utils/web_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const enrollmentTime = 'Fri, 22 Sep 2017 01:49:58 GMT';
  final expectedTimestamp =
      DateTime.utc(2017, 9, 22, 1, 49, 58).millisecondsSinceEpoch / 1000;

  JSObject buildJsFactorInfo({
    required String factorId,
    String? displayName = 'Work factor',
    String? phoneNumber,
  }) {
    final info = JSObject();
    info['uid'] = 'factor-uid-1'.toJS;
    info['factorId'] = factorId.toJS;
    info['enrollmentTime'] = enrollmentTime.toJS;
    if (displayName != null) {
      info['displayName'] = displayName.toJS;
    }
    if (phoneNumber != null) {
      info['phoneNumber'] = phoneNumber.toJS;
    }
    return info;
  }

  test('converts PhoneMultiFactorInfo and parses RFC 1123 enrollmentTime', () {
    final interopInfo = multi_factor_interop.fromJsMultiFactorInfo(
      buildJsFactorInfo(
        factorId: 'phone',
        phoneNumber: '+16505550101',
      ) as auth_interop.MultiFactorInfoJsImpl,
    );

    final result = fromInteropMultiFactorInfo(interopInfo);

    expect(
      result,
      isA<PhoneMultiFactorInfo>()
          .having((i) => i.uid, 'uid', 'factor-uid-1')
          .having((i) => i.factorId, 'factorId', 'phone')
          .having((i) => i.displayName, 'displayName', 'Work factor')
          .having((i) => i.phoneNumber, 'phoneNumber', '+16505550101')
          .having(
            (i) => i.enrollmentTimestamp,
            'enrollmentTimestamp',
            expectedTimestamp,
          ),
    );
  });

  test('converts TotpMultiFactorInfo and parses RFC 1123 enrollmentTime', () {
    final interopInfo = multi_factor_interop.fromJsMultiFactorInfo(
      buildJsFactorInfo(factorId: 'totp') as auth_interop.MultiFactorInfoJsImpl,
    );

    final result = fromInteropMultiFactorInfo(interopInfo);

    expect(
      result,
      isA<TotpMultiFactorInfo>()
          .having((i) => i.uid, 'uid', 'factor-uid-1')
          .having((i) => i.factorId, 'factorId', 'totp')
          .having((i) => i.displayName, 'displayName', 'Work factor')
          .having(
            (i) => i.enrollmentTimestamp,
            'enrollmentTimestamp',
            expectedTimestamp,
          ),
    );
  });

  test('converts generic MultiFactorInfo and parses RFC 1123 enrollmentTime',
      () {
    final interopInfo = multi_factor_interop.fromJsMultiFactorInfo(
      buildJsFactorInfo(factorId: 'custom', displayName: null)
          as auth_interop.MultiFactorInfoJsImpl,
    );

    final result = fromInteropMultiFactorInfo(interopInfo);

    expect(result, isA<MultiFactorInfo>());
    expect(result, isNot(isA<PhoneMultiFactorInfo>()));
    expect(result, isNot(isA<TotpMultiFactorInfo>()));
    expect(result.uid, 'factor-uid-1');
    expect(result.factorId, 'custom');
    expect(result.displayName, isNull);
    expect(result.enrollmentTimestamp, expectedTimestamp);
  });
}
