// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// CI shard entrypoint. `e2e_test.dart` still runs every suite in one process
// (Windows and local runs use it); CI splits that run across shards so a hang
// or flake costs one small job instead of the whole suite.
//
// Database runs before Cloud Functions, matching `e2e_test.dart`. Auth lives in
// its own shard, so the Auth-leaves-emulator-state-that-interferes-with-Database
// problem `e2e_test.dart` works around on web cannot happen here at all: the
// shards are separate processes against separate emulator suites.

import '../cloud_functions/cloud_functions_e2e_test.dart' as cloud_functions;
import '../firebase_database/firebase_database_e2e_test.dart'
    as firebase_database;

void main() {
  firebase_database.main();
  cloud_functions.main();
}
