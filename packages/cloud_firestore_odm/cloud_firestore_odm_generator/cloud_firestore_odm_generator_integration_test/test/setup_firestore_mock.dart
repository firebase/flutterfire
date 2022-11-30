// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> setupCloudFirestoreMocks() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  setupFirebaseCoreMocks();
  await Firebase.initializeApp();
}
