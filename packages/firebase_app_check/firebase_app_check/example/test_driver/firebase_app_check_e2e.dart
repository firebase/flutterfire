// @dart = 2.9

// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:drive/drive.dart' as drive;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

void testsMain() {
  setUpAll(() async {
    await Firebase.initializeApp();
  });

  // TODO: Setup some e2e tests.
}

void main() => drive.main(testsMain);
