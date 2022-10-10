// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mock.dart';

void main() {
  setupFirebaseDatabaseMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  group('instance', () {
    test('ensure databaseUrl is correct', () {
      String secondDb = 'https://second-db.firebaseio.com';
      final shared = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: secondDb,
      );

      expect(shared.databaseURL, secondDb);
    });

    test(
        'ensure databaseUrl has "/" removed on FirebaseDatabase initialisation',
        () {
      String secondDb = 'https://second-db.firebaseio.com';
      final shared = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        // add forward slash to end
        databaseURL: '$secondDb/',
      );

      expect(shared.databaseURL, secondDb);
    });
  });
}
