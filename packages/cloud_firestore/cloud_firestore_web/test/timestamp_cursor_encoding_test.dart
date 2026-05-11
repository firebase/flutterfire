// Copyright 2026, the Chromium project authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('chrome')

import 'dart:js_interop';

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:cloud_firestore_web/src/interop/firestore_interop.dart';
import 'package:cloud_firestore_web/src/utils/encode_utility.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('EncodeUtility.valueEncode preserves Timestamp nanoseconds', () {
    const seconds = 1;
    const nanoseconds = 123456789;
    final ts = Timestamp(seconds, nanoseconds);
    final encoded = EncodeUtility.valueEncode(ts) as TimestampJsImpl;
    expect(encoded.seconds.toDartInt, seconds);
    expect(encoded.nanoseconds.toDartInt, nanoseconds);
  });
}
