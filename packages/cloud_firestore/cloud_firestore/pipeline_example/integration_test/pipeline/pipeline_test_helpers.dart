// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

/// Asserts that [snapshot] has exactly [count] results.
void expectResultCount(PipelineSnapshot snapshot, int count) {
  expect(
    snapshot.result.length,
    count,
    reason: 'Expected $count pipeline results',
  );
}

/// Asserts that [snapshot] has the same number of results as [expectedData]
/// and each result's data() deep-equals the corresponding expected map.
/// Keys in [expectedData] are checked; extra keys in actual data are ignored
/// when [exactMatch] is false (default). Set [exactMatch] to true to require
/// identical keys.
void expectResultsData(
  PipelineSnapshot snapshot,
  List<Map<String, dynamic>> expectedData, {
  bool exactMatch = false,
}) {
  expect(
    snapshot.result.length,
    expectedData.length,
    reason: 'Result count mismatch',
  );
  for (var i = 0; i < expectedData.length; i++) {
    final result = snapshot.result[i];
    final data = result.data();
    expect(data, isNotNull, reason: 'Result $i has null data');
    final actual = data!;
    final expected = expectedData[i];
    if (exactMatch) {
      expect(actual, expected, reason: 'Result $i data mismatch');
    } else {
      for (final entry in expected.entries) {
        expect(
          actual[entry.key],
          entry.value,
          reason: 'Result $i field ${entry.key}',
        );
      }
    }
  }
}
