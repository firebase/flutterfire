// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils/test_firestore_message_codec.dart';

void main() {
  const TestFirestoreMessageCodec codec = TestFirestoreMessageCodec();

  test('encodes DateTime without losing microseconds', () {
    final dates = <DateTime>[
      DateTime.utc(2023, 11, 1, 0, 0, 0, 0, 1),
      DateTime.utc(2023, 11, 1, 0, 0, 0, 1, 1),
      DateTime.utc(2023, 11, 1, 0, 0, 0, 999, 999),
      DateTime.utc(1969, 12, 31, 23, 59, 59, 999, 999),
    ];

    for (final date in dates) {
      final encoded = codec.encodeMessage(date);
      final decoded = codec.decodeMessage(encoded);

      expect(decoded, Timestamp.fromDate(date));
    }
  });
}
