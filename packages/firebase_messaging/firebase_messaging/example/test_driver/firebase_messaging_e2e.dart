// ignore_for_file: require_trailing_commas

// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// @dart=2.9

import 'package:drive/drive.dart' as drive;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'instance_e2e.dart';

// Requires that an emulator is running locally
bool USE_EMULATOR = false;

void testsMain() {
  setUpAll(() async {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
      apiKey: 'AIzaSyAHAsf51D0A407EklG1bs-5wA7EbyfNFg0',
      appId: '1:448618578101:ios:2bc5c1fe2ec336f8ac3efc',
      messagingSenderId: '448618578101',
      projectId: 'react-native-firebase-testing',
    ));
  });

  runInstanceTests();
}

void main() => drive.main(testsMain);
