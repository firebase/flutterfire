// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// CI entrypoint for the `tests` app; `e2e_test.dart` is the identical
// local-run and Windows target.
//
// It holds firebase_core, the only suite left here: every other product now
// runs its own suite from its own example app. It doubles as the coexistence
// smoke test - the `tests` app depends on every plugin, so building this target
// still proves they all compile and link together, which no single-product
// example can show.

import 'package:integration_test/integration_test.dart';

import '../firebase_core/firebase_core_e2e_test.dart' as firebase_core;
import '../report_test_results.dart';

void main() {
  // `firebase_core.main()` calls `ensureInitialized()` itself, but the hook has
  // to be registered before the suite declares its groups, so initialize here
  // too - `ensureInitialized()` is idempotent and returns the same binding.
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  reportTestResultsToDriver(binding);

  firebase_core.main();
}
