// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

const int _kBillion = 1000000000;
const int _kStartOfTime = -62135596800;
const int _kEndOfTime = 253402300800;

void main() {
  group('$Timestamp', () {
    test('equality', () {
      expect(Timestamp(0, 0), equals(Timestamp(0, 0)));
      expect(Timestamp(123, 456), equals(Timestamp(123, 456)));
    });

    test('validation', () {
      expect(() => Timestamp(0, -1), throwsArgumentError);
      expect(() => Timestamp(0, _kBillion + 1), throwsArgumentError);
      expect(() => Timestamp(_kStartOfTime - 1, 123), throwsArgumentError);
      expect(() => Timestamp(_kEndOfTime + 1, 123), throwsArgumentError);
    });

    test('returns properties', () {
      Timestamp t = Timestamp(123, 456);
      expect(t.seconds, equals(123));
      expect(t.nanoseconds, equals(456));
    });

    // https://github.com/FirebaseExtended/flutterfire/issues/1222
    test('does not exceed range', () {
      Timestamp maxTimestamp = Timestamp(_kEndOfTime - 1, _kBillion - 1);
      Timestamp.fromMicrosecondsSinceEpoch(maxTimestamp.microsecondsSinceEpoch);
    });
  });
}
