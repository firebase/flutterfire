// ignore_for_file: require_trailing_commas
// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// import 'package:flutter/services.dart';
import 'package:firebase_storage_platform_interface/firebase_storage_platform_interface.dart';
import 'package:firebase_storage_web/src/utils/metadata_cache.dart';
import 'package:flutter_test/flutter_test.dart';

final someMetadata = SettableMetadata(contentLanguage: 'es', customMetadata: {
  'testing': '123',
});

final otherMetadata = SettableMetadata(
  contentType: 'image/png',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  SettableMetadataCache? cache;

  setUp(() {
    cache = SettableMetadataCache();
  });

  tearDown(() {});

  group('store()', () {
    group('overwrite = false', () {
      setUp(() {
        cache!.store(someMetadata);
      });

      test('Merges metadata and keeps what is not set again', () {
        final setMetadata = cache!.store(otherMetadata);

        expect(
            setMetadata.contentLanguage, equals(someMetadata.contentLanguage));
        expect(setMetadata.contentType, equals(otherMetadata.contentType));
      });

      test('New values replace the cached ones', () {
        final setMetadata = cache!.store(SettableMetadata(
          contentLanguage: 'fr',
        ));

        expect(setMetadata.contentLanguage, equals('fr'));
        expect(setMetadata.customMetadata, equals({'testing': '123'}));
      });

      test('Shallowly merges customMetadata, new values win', () {
        final withCustomMetadata = SettableMetadata(customMetadata: {
          'testing': '456',
          'more-testing': 'yes',
        });

        final setMetadata = cache!.store(withCustomMetadata);
        final customMetadata = setMetadata.customMetadata;
        expect(customMetadata, containsPair('testing', '456'));
        expect(customMetadata, containsPair('more-testing', 'yes'));
      });

      test('Storing null returns the current cache', () {
        final setMetadata = cache!.store(null);

        expect(
            setMetadata.contentLanguage, equals(someMetadata.contentLanguage));
      });
    });

    group('overwrite = true', () {
      setUp(() {
        cache!.store(someMetadata);
      });

      test('Rewrites whole contents of cache', () {
        final setMetadata = cache!.store(otherMetadata, overwrite: true);

        expect(setMetadata.contentLanguage, isNull);
        expect(setMetadata, equals(otherMetadata));
      });

      test('Cache does not become null', () {
        final setMetadata = cache!.store(null, overwrite: true);

        expect(setMetadata, isA<SettableMetadata>());
        expect(setMetadata, isNotNull);
      });
    });
  });
}
