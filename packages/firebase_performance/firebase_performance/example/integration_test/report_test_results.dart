// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/common.dart' show Failure;
import 'package:integration_test/integration_test.dart';

/// Copies per-test results into [IntegrationTestWidgetsFlutterBinding.reportData]
/// so the web driver can print them; on web nothing else crosses the wire.
void reportTestResultsToDriver(IntegrationTestWidgetsFlutterBinding binding) {
  tearDownAll(() {
    binding.reportData ??= <String, dynamic>{};
    binding.reportData!['testResults'] = <String, String>{
      for (final entry in binding.results.entries)
        entry.key: entry.value is Failure ? 'failed' : 'success',
    };
  });
}
