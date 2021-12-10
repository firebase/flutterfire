// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:drive/drive.dart' as drive;
import 'firebase_core/firebase_core_e2e.dart' as firebase_core;

void setupTests() {
  firebase_core.setupTests();
}

void main() => drive.main(setupTests);
