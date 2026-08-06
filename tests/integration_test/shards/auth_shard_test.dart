// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// CI shard entrypoint. `e2e_test.dart` still runs every suite in one process
// (Windows and local runs use it); CI splits that run across shards so a hang
// or flake costs one small job instead of the whole suite.

import '../firebase_auth/firebase_auth_e2e_test.dart' as firebase_auth;

void main() {
  firebase_auth.main();
}
