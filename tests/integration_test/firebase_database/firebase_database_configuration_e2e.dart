// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tests/firebase_options.dart';

import 'firebase_database_e2e_test.dart';

const MAX_CACHE_SIZE = 100 * 1024 * 1024;
const MIN_CACHE_SIZE = 1042 * 1024;

void setupConfigurationTests() {
  group('FirebaseDatabase configuration', () {
    test(
      'setPersistenceCacheSizeBytes Integer',
      () {
        database.setPersistenceCacheSizeBytes(MIN_CACHE_SIZE);
      },
      // Skipped because it is not supported on web
      skip: kIsWeb,
    );

    test(
      'setPersistenceCacheSizeBytes Long',
      () {
        database.setPersistenceCacheSizeBytes(MAX_CACHE_SIZE);
      },
      // Skipped because it is not supported on web
      skip: kIsWeb,
    );

    test('setLoggingEnabled to true', () {
      database.setLoggingEnabled(true);
    });

    test('setLoggingEnabled to false', () {
      database.setLoggingEnabled(false);
    });

    test(
      'setPersistenceEnabled can be followed immediately by goOnline',
      () async {
        for (var i = 0; i < 5; i++) {
          final app = await Firebase.initializeApp(
            name:
                'firebase-database-persistence-${DateTime.now().microsecondsSinceEpoch}-$i',
            options: DefaultFirebaseOptions.currentPlatform,
          );
          addTearDown(app.delete);

          final database = FirebaseDatabase.instanceFor(app: app);

          database.setPersistenceEnabled(true);
          await database.goOnline();

          await database.ref('persistence-enabled-regression').keepSynced(true);
          await database
              .ref('persistence-enabled-regression')
              .keepSynced(false);
          await database.goOffline();
        }
      },
      skip: kIsWeb || defaultTargetPlatform != TargetPlatform.android,
    );
  });
}
