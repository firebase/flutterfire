// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// The `tests` app used to aggregate every product's e2e suite. All thirteen
// products now own their suite inside their own example app, each driven by its
// own path-filtered `.github/workflows/e2e_tests_<product>.yaml`.
//
// What is left here is the all-plugins coexistence smoke test: `tests` still
// depends on every plugin (see `tests/pubspec.yaml`), so building and running
// this target proves the whole set still compiles, links and boots together -
// something no single-product example can show. firebase_core is the suite it
// runs, because it is the only one with no live backend behind it.
//
// `shards/core_shard_test.dart` is the same thing under the name CI uses; this
// file stays as the local-run entrypoint (`flutter test integration_test`) and
// as the Windows target.

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'firebase_core/firebase_core_e2e_test.dart' as firebase_core;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('FlutterFire', runAllTests);
}

void runAllTests() {
  firebase_core.main();
}
