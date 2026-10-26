// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_auth_web/src/auth_emulator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('shouldSkipConnectAuthEmulator', () {
    test('does not skip when this Auth instance is not on the emulator', () {
      expect(
        shouldSkipConnectAuthEmulator(
          requestedOrigin: 'http://localhost:9099',
          connectedEmulatorOrigin: null,
        ),
        isFalse,
      );
    });

    test(
      'does not skip when sessionStorage would match but this instance is on production',
      () {
        // This is the #18689 reload: leftover sessionStorage is not passed in
        // here on purpose. Skip must key off the live JS Auth config only.
        expect(
          shouldSkipConnectAuthEmulator(
            requestedOrigin: 'http://localhost:9099',
            connectedEmulatorOrigin: null,
          ),
          isFalse,
        );
      },
    );

    test('skips when this Auth instance is already on the requested origin',
        () {
      expect(
        shouldSkipConnectAuthEmulator(
          requestedOrigin: 'http://localhost:9099',
          connectedEmulatorOrigin: 'http://localhost:9099',
        ),
        isTrue,
      );
    });

    test('does not skip when the connected origin is different', () {
      expect(
        shouldSkipConnectAuthEmulator(
          requestedOrigin: 'http://localhost:9099',
          connectedEmulatorOrigin: 'http://127.0.0.1:9099',
        ),
        isFalse,
      );
    });
  });

  group('shouldReusePersistedAuthEmulator', () {
    const stored = 'http://localhost:9099';

    test('reuses stored origin on localhost in debug', () {
      expect(
        shouldReusePersistedAuthEmulator(
          hostname: 'localhost',
          isDebugMode: true,
          storedOrigin: stored,
        ),
        isTrue,
      );
    });

    test('reuses stored origin on 127.0.0.1 in debug', () {
      expect(
        shouldReusePersistedAuthEmulator(
          hostname: '127.0.0.1',
          isDebugMode: true,
          storedOrigin: stored,
        ),
        isTrue,
      );
    });

    test('reuses stored origin on [::1] in debug', () {
      expect(
        shouldReusePersistedAuthEmulator(
          hostname: '[::1]',
          isDebugMode: true,
          storedOrigin: stored,
        ),
        isTrue,
      );
    });

    test('does not reuse when hostname is not loopback', () {
      expect(
        shouldReusePersistedAuthEmulator(
          hostname: 'example.com',
          isDebugMode: true,
          storedOrigin: stored,
        ),
        isFalse,
      );
    });

    test('does not reuse when nothing is stored', () {
      expect(
        shouldReusePersistedAuthEmulator(
          hostname: '127.0.0.1',
          isDebugMode: true,
          storedOrigin: null,
        ),
        isFalse,
      );
    });

    test('does not reuse outside debug', () {
      expect(
        shouldReusePersistedAuthEmulator(
          hostname: 'localhost',
          isDebugMode: false,
          storedOrigin: stored,
        ),
        isFalse,
      );
    });
  });

  test('authEmulatorOriginStorageKey is per app', () {
    expect(
      authEmulatorOriginStorageKey('[DEFAULT]'),
      '[DEFAULT]-firebaseEmulatorOrigin',
    );
  });
}
