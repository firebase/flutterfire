import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'firebase_database_e2e.dart';

const MAX_CACHE_SIZE = 100 * 1024 * 1024;
const MIN_CACHE_SIZE = 1042 * 1024;

void runConfigurationTests() {
  group('FirebaseDatabase configuration', () {
    test(
      'setPersistenceCacheSizeBytes Integer',
      () async {
        await database.setPersistenceCacheSizeBytes(MIN_CACHE_SIZE);
      },
      // Skipped because it is not supported on web
      skip: kIsWeb,
    );

    test(
      'setPersistenceCacheSizeBytes Long',
      () async {
        await database.setPersistenceCacheSizeBytes(MAX_CACHE_SIZE);
      },
      // Skipped because it is not supported on web
      skip: kIsWeb,
    );

    test('setLoggingEnabled to true', () async {
      await database.setLoggingEnabled(true);
    });

    test('setLoggingEnabled to false', () async {
      await database.setLoggingEnabled(false);
    });

    test(
      'throws exception if configuration is performed '
      'before any other database usage',
      () async {
        await database.ref('flutterfire').set(0);

        try {
          await database.setLoggingEnabled(true);
          throw Exception('should throw FirebaseDatabaseException');
        } catch (err) {
          expect(err, isA<FirebaseDatabaseException>());
          expect(
            (err as FirebaseDatabaseException).code,
            'wrong-configuration-point',
          );
        }
      },
      skip: kIsWeb,
    );
  });
}
