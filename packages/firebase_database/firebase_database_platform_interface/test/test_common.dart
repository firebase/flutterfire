// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../../firebase_core/firebase_core_platform_interface/test/test.dart';
import 'package:flutter_test/flutter_test.dart';

void initializeMethodChannel() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();
}
