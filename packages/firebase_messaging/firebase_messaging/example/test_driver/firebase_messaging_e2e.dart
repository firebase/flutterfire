// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:drive/drive.dart' as drive;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'instance_e2e.dart';

// Requires that an emulator is running locally
bool USE_EMULATOR = false;

void testsMain() {
  setUpAll(() async {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyAgUhHU8wSJgO5MVNy95tMT07NEjzMOfz0',
          authDomain: 'react-native-firebase-testing.firebaseapp.com',
          databaseURL: 'https://react-native-firebase-testing.firebaseio.com',
          projectId: 'react-native-firebase-testing',
          storageBucket: 'react-native-firebase-testing.appspot.com',
          messagingSenderId: '448618578101',
          appId: '1:448618578101:web:772d484dc9eb15e9ac3efc',
          measurementId: 'G-0N1G9FLDZE',
        ),
      );
    } else if (!Platform.isMacOS) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyAHAsf51D0A407EklG1bs-5wA7EbyfNFg0',
          appId: '1:448618578101:ios:0b11ed8263232715ac3efc',
          messagingSenderId: '448618578101',
          projectId: 'react-native-firebase-testing',
          iosBundleId: 'io.flutter.plugins.firebase.messaging',
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
  });

  runInstanceTests();
}

void main() => drive.main(testsMain);
