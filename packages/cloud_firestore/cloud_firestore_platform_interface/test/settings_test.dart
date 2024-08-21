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
  });
}

mixin _Noop {}

class ExtendedSettings = Settings with _Noop;
