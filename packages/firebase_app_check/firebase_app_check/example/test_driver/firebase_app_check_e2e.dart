// ignore_for_file: require_trailing_commas
// @dart = 2.9

// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:drive/drive.dart' as drive;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

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

  // TODO: Setup some e2e tests.
}

void main() => drive.main(testsMain);
