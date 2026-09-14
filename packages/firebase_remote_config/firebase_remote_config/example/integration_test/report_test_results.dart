// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/common.dart' show Failure;
import 'package:integration_test/integration_test.dart';
import 'package:test_api/hooks.dart' show TestHandle;

/// Records every executed test via the package:test lifecycle (plain `test()`
/// declarations never reach the binding's `results` map - only `testWidgets`
/// does) and publishes them through
/// [IntegrationTestWidgetsFlutterBinding.reportData], the only channel that
/// crosses the wire on web.
void reportTestResultsToDriver(IntegrationTestWidgetsFlutterBinding binding) {
  final executed = <String>[];
  setUp(() {
    executed.add(TestHandle.current.name);
  });
  tearDownAll(() {
    // `TestHandle.current.name` is the full name, prefixed with the enclosing
    // group names, while `binding.results` is keyed by the bare `testWidgets`
    // description - so match a failed entry on the suffix as well as on
    // equality, otherwise no grouped test could ever be marked failed.
    final failures = <String>[
      for (final entry in binding.results.entries)
        if (entry.value is Failure) entry.key,
    ];
    bool didFail(String name) => failures
        .any((failure) => name == failure || name.endsWith(' $failure'));

    binding.reportData ??= <String, dynamic>{};
    binding.reportData!['testResults'] = <String, String>{
      // Plain test() failures are not individually attributable here, but they
      // fail the run as a whole via allTestsPassed; testWidgets failures are
      // attributed from the binding's results map.
      for (final name in executed) name: didFail(name) ? 'failed' : 'success',
    };
  });
}
