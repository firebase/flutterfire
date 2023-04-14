// Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_ui_storage/firebase_ui_storage.dart';
import 'package:firebase_ui_storage/src/config.dart';
import 'package:firebase_ui_storage/src/lib.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mocks.dart';

void main() {
  setUp(() {
    resetConfigs();
  });

  group('KeepPathUploadPolicy', () {
    group('getFileName()', () {
      test('returns file name', () {
        const path = 'path/to/file.txt';
        const policy = KeepPathUploadPolicy();
        expect(policy.getUploadFileName(path), 'path/to/file.txt');
      });
    });
  });

  group('KeepOriginalNameUploadPolicy', () {
    group('getFileName()', () {
      test('returns file name', () {
        const path = 'path/to/file.txt';
        const policy = KeepOriginalNameUploadPolicy();
        expect(policy.getUploadFileName(path), 'file.txt');
      });
    });
  });

  group('UuidFileUploadNamingPolicy', () {
    group('getFileName()', () {
      test('generates a uuid and preserves file extension', () {
        const path = 'path/to/file.txt';
        final policy = UuidFileUploadNamingPolicy(uuid: MockUUID());
        expect(policy.getUploadFileName(path), '${MockUUID.value}.txt');
      });
    });
  });

  group('FirebaseUIStorageConfigOverride', () {
    testWidgets(
      'allows to override a top-level configuration',
      (tester) async {
        final initialConfig = FirebaseUIStorageConfiguration(
          storage: MockStorage.instance,
        );

        final overriden = FirebaseUIStorageConfiguration(
          storage: MockStorage.instance,
          namingPolicy: const UuidFileUploadNamingPolicy(),
        );

        FirebaseUIStorage.configure(initialConfig);

        await tester.pumpWidget(
          Builder(builder: (context) {
            final config = context.configFor(MockStorage.instance);
            expect(config, initialConfig);

            return FirebaseUIStorageConfigOverride(
              config: overriden,
              child: Builder(builder: (context) {
                final config = context.configFor(MockStorage.instance);
                expect(config, overriden);
                return const SizedBox();
              }),
            );
          }),
        );
      },
    );
  });
}
