// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('$Settings', () {
    test('equality', () {
      expect(
        const Settings(
          persistenceEnabled: true,
          host: 'foo bar',
          sslEnabled: true,
          webExperimentalForceLongPolling: false,
          webExperimentalAutoDetectLongPolling: false,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
          webExperimentalLongPollingOptions: WebExperimentalLongPollingOptions(
            timeoutDuration: Duration(seconds: 4),
          ),
          webPersistentTabManager: WebPersistentMultipleTabManager(),
        ),
        equals(
          const Settings(
            persistenceEnabled: true,
            host: 'foo bar',
            sslEnabled: true,
            webExperimentalForceLongPolling: false,
            webExperimentalAutoDetectLongPolling: false,
            cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
            webExperimentalLongPollingOptions:
                WebExperimentalLongPollingOptions(
              timeoutDuration: Duration(seconds: 4),
            ),
            webPersistentTabManager: WebPersistentMultipleTabManager(),
          ),
        ),
      );

      expect(
        const Settings(
          persistenceEnabled: true,
          host: 'foo bar',
          sslEnabled: true,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        ),
        isNot(
          const ExtendedSettings(
            persistenceEnabled: true,
            host: 'foo bar',
            sslEnabled: true,
            cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
          ),
        ),
      );
    });

    test('hashCode', () {
      const settings = Settings(
        persistenceEnabled: true,
        host: 'foo bar',
        sslEnabled: true,
        webExperimentalAutoDetectLongPolling: false,
        webExperimentalForceLongPolling: false,
        webExperimentalLongPollingOptions: WebExperimentalLongPollingOptions(
          timeoutDuration: Duration(seconds: 4),
        ),
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      expect(settings.hashCode, equals(settings.hashCode));
    });

    test('returns a map of settings', () {
      expect(const Settings().asMap, <String, dynamic>{
        'persistenceEnabled': null,
        'host': null,
        'sslEnabled': null,
        'cacheSizeBytes': null,
        'webExperimentalForceLongPolling': null,
        'webExperimentalAutoDetectLongPolling': null,
        'webExperimentalLongPollingOptions': null,
      });

      expect(
          const Settings(
              persistenceEnabled: true,
              host: 'foo bar',
              sslEnabled: true,
              cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
              webExperimentalAutoDetectLongPolling: true,
              webExperimentalForceLongPolling: true,
              webExperimentalLongPollingOptions:
                  WebExperimentalLongPollingOptions(
                timeoutDuration: Duration(seconds: 4),
              )).asMap,
          <String, dynamic>{
            'persistenceEnabled': true,
            'host': 'foo bar',
            'sslEnabled': true,
            'cacheSizeBytes': Settings.CACHE_SIZE_UNLIMITED,
            'webExperimentalForceLongPolling': true,
            'webExperimentalAutoDetectLongPolling': true,
            'webExperimentalLongPollingOptions':
                const WebExperimentalLongPollingOptions(
              timeoutDuration: Duration(seconds: 4),
            ).asMap
          });
    });

    test('CACHE_SIZE_UNLIMITED returns -1', () {
      expect(Settings.CACHE_SIZE_UNLIMITED, equals(-1));
    });

    test('WebPersistentTabManager equality', () {
      expect(
        const WebPersistentMultipleTabManager(),
        equals(const WebPersistentMultipleTabManager()),
      );

      expect(
        const WebPersistentSingleTabManager(),
        equals(const WebPersistentSingleTabManager()),
      );

      expect(
        const WebPersistentSingleTabManager(forceOwnership: true),
        equals(const WebPersistentSingleTabManager(forceOwnership: true)),
      );

      expect(
        const WebPersistentSingleTabManager(forceOwnership: true),
        isNot(equals(const WebPersistentSingleTabManager())),
      );

      expect(
        const WebPersistentMultipleTabManager(),
        isNot(equals(const WebPersistentSingleTabManager())),
      );
    });

    test('Settings with different webPersistentTabManager are not equal', () {
      expect(
        const Settings(
          persistenceEnabled: true,
          webPersistentTabManager: WebPersistentMultipleTabManager(),
        ),
        isNot(equals(
          const Settings(
            persistenceEnabled: true,
            webPersistentTabManager: WebPersistentSingleTabManager(),
          ),
        )),
      );
    });

    test('copyWith preserves webPersistentTabManager', () {
      const settings = Settings(
        persistenceEnabled: true,
        webPersistentTabManager: WebPersistentMultipleTabManager(),
      );

      final copied = settings.copyWith(host: 'localhost');

      expect(copied.webPersistentTabManager,
          isA<WebPersistentMultipleTabManager>());
      expect(copied.host, 'localhost');
      expect(copied.persistenceEnabled, true);
    });
  });
}

mixin _Noop {}

class ExtendedSettings = Settings with _Noop;
