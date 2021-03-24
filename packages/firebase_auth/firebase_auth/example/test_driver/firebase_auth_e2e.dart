// @dart = 2.9

// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// @dart=2.9

import 'package:drive/drive.dart' as drive;
//import 'package:firebase_auth/firebase_auth.dart'; // only needed if you use the Auth Emulator
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'instance_e2e.dart';
import 'user_e2e.dart';

// Requires that an emulator is running locally
bool USE_EMULATOR = false;

void testsMain() {
  setUpAll(() async {
    await Firebase.initializeApp();

    // Configure the Auth test suite to use the Auth Emulator
    // This may not be enabled until the test suite is ported to:
    //  - have ability to create disabled users
    //  - have ability to fetch OOB and SMS verification codes
    // JS implementation to port to dart here: https://github.com/invertase/react-native-firebase/pull/4552/commits/4c688413cb6516ecfdbd4ea325103d0d8d8d84a8#diff-44ccd5fb03b0d9e447820032866f2494c5a400a52873f0f65518d06aedafe302
    // await FirebaseAuth.instance.useEmulator('http://localhost:9099');
  });

  runInstanceTests();
  runUserTests();
}

void main() => drive.main(testsMain);
