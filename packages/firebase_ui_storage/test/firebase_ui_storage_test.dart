// Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_ui_storage/firebase_ui_storage.dart';
import 'package:firebase_ui_storage/src/lib.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mocks.dart';

void main() {
  final storage = MockStorage();
  final config = FirebaseUIStorageConfiguration(storage: storage);

  setUp(() {
    resetConfigs();
  });

  group('FirebaseUIStorage', () {
    group('configureProviders()', () {
      test(
        'sets a configuration for a given FirebaseStorage instance',
        () async {
          await FirebaseUIStorage.configure(config);
          expect(FirebaseUIStorage.isConfigured(config.storage), isTrue);
        },
      );

      test(
        'throws an error if already configured',
        () async {
          await FirebaseUIStorage.configure(config);
          expect(
            () => FirebaseUIStorage.configure(config),
            throwsA(isA<StateError>()),
          );
        },
      );
    });

    group('configurationFor()', () {
      test(
        'returns a configuration for a given FirebaseStorage instance',
        () async {
          await FirebaseUIStorage.configure(config);
          expect(FirebaseUIStorage.configurationFor(storage), config);
        },
      );

      test(
        'throws an error if not configured',
        () async {
          expect(
            () => FirebaseUIStorage.configurationFor(config.storage),
            throwsA(isA<StateError>()),
          );
        },
      );
    });

    group('isConfigured()', () {
      test(
        'returns true if a configuration is set for a given FirebaseStorage '
        'instance',
        () async {
          await FirebaseUIStorage.configure(config);
          expect(FirebaseUIStorage.isConfigured(storage), isTrue);
        },
      );

      test(
        'returns false if a configuration is not set for a given '
        'FirebaseStorage instance',
        () async {
          expect(FirebaseUIStorage.isConfigured(storage), isFalse);
        },
      );
    });
  });
}
