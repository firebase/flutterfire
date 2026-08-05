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

import '../firebase_core/firebase_core_e2e_test.dart' as firebase_core;

void main() {
  firebase_core.main();
}
