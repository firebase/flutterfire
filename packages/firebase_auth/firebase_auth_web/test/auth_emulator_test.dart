// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
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

    test(
      'skips when this Auth instance is already on the requested origin',
      () {
        expect(
          shouldSkipConnectAuthEmulator(
            requestedOrigin: 'http://localhost:9099',
            connectedEmulatorOrigin: 'http://localhost:9099',
          ),
          isTrue,
        );
      },
    );

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

    test('reuses stored origin on localhost when persistence is on', () {
      expect(
        shouldReusePersistedAuthEmulator(
          hostname: 'localhost',
          persistOrigin: true,
          storedOrigin: stored,
        ),
        isTrue,
      );
    });

    test('reuses stored origin on 127.0.0.1 when persistence is on', () {
      expect(
        shouldReusePersistedAuthEmulator(
          hostname: '127.0.0.1',
          persistOrigin: true,
          storedOrigin: stored,
        ),
        isTrue,
      );
    });

    test('reuses stored origin on [::1] when persistence is on', () {
      expect(
        shouldReusePersistedAuthEmulator(
          hostname: '[::1]',
          persistOrigin: true,
          storedOrigin: stored,
        ),
        isTrue,
      );
    });

    test('does not reuse when hostname is not loopback', () {
      expect(
        shouldReusePersistedAuthEmulator(
          hostname: 'example.com',
          persistOrigin: true,
          storedOrigin: stored,
        ),
        isFalse,
      );
    });

    test('does not reuse when nothing is stored', () {
      expect(
        shouldReusePersistedAuthEmulator(
          hostname: '127.0.0.1',
          persistOrigin: true,
          storedOrigin: null,
        ),
        isFalse,
      );
    });

    test('does not reuse when persistence is off', () {
      expect(
        shouldReusePersistedAuthEmulator(
          hostname: 'localhost',
          persistOrigin: false,
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

  group('debugAuthEmulatorOrigin', () {
    test('does not touch storage when persistence is off', () {
      var localReads = 0;
      var sessionReads = 0;
      expect(
        debugAuthEmulatorOrigin(
          persistOrigin: false,
          readLocal: () {
            localReads++;
            return 'http://localhost:9099';
          },
          readSession: () {
            sessionReads++;
            return 'http://127.0.0.1:9099';
          },
        ),
        isNull,
      );
      expect(localReads, 0);
      expect(sessionReads, 0);
    });

    test('returns null when storage throws', () {
      expect(
        debugAuthEmulatorOrigin(
          persistOrigin: true,
          readLocal: () => throw StateError('blocked'),
          readSession: () => 'http://localhost:9099',
        ),
        isNull,
      );
    });

    test('reads a refused connect from sessionStorage before localStorage', () {
      expect(
        debugAuthEmulatorOrigin(
          persistOrigin: true,
          readLocal: () => 'http://localhost:9099',
          readSession: () => 'http://127.0.0.1:9099',
        ),
        'http://127.0.0.1:9099',
      );
    });
  });

  group('rememberDebugAuthEmulatorOrigin', () {
    test('does not write when persistence is off', () {
      var writes = 0;
      rememberDebugAuthEmulatorOrigin(
        persistOrigin: false,
        write: () => writes++,
      );
      expect(writes, 0);
    });

    test('writes once when persistence is on', () {
      var writes = 0;
      rememberDebugAuthEmulatorOrigin(
        persistOrigin: true,
        write: () => writes++,
      );
      expect(writes, 1);
    });

    test('swallows a write that throws', () {
      rememberDebugAuthEmulatorOrigin(
        persistOrigin: true,
        write: () => throw StateError('blocked'),
      );
    });
  });

  group('persistedAuthEmulatorOrigin', () {
    test('uses a refused connect from sessionStorage before localStorage', () {
      expect(
        persistedAuthEmulatorOrigin(
          localOrigin: 'http://localhost:9099',
          sessionOrigin: 'http://127.0.0.1:9099',
        ),
        'http://127.0.0.1:9099',
      );
    });

    test('uses localStorage when this tab has no pending connect', () {
      expect(
        persistedAuthEmulatorOrigin(
          localOrigin: 'http://localhost:9099',
          sessionOrigin: null,
        ),
        'http://localhost:9099',
      );
    });

    test('uses sessionStorage when localStorage is empty', () {
      expect(
        persistedAuthEmulatorOrigin(
          localOrigin: null,
          sessionOrigin: 'http://localhost:9099',
        ),
        'http://localhost:9099',
      );
    });

    test('returns null when neither store has an origin', () {
      expect(
        persistedAuthEmulatorOrigin(localOrigin: null, sessionOrigin: null),
        isNull,
      );
    });
  });

  group('shouldRememberRequestedOriginAfterFailedConnect', () {
    test('stores a different origin for the next launch', () {
      expect(
        shouldRememberRequestedOriginAfterFailedConnect(
          requestedOrigin: 'http://127.0.0.1:9100',
          connectedOrigin: 'http://localhost:9099',
        ),
        isTrue,
      );
    });

    test('stores the request when this instance is still on production', () {
      expect(
        shouldRememberRequestedOriginAfterFailedConnect(
          requestedOrigin: 'http://localhost:9099',
          connectedOrigin: null,
        ),
        isTrue,
      );
    });

    test('does not rewrite an origin this instance is already using', () {
      expect(
        shouldRememberRequestedOriginAfterFailedConnect(
          requestedOrigin: 'http://localhost:9099',
          connectedOrigin: 'http://localhost:9099',
        ),
        isFalse,
      );
    });
  });

  group('authEmulatorConnectTooLateMessage', () {
    test('says production and asks for a full page reload', () {
      final message = authEmulatorConnectTooLateMessage(
        appName: '[DEFAULT]',
        requestedOrigin: 'http://localhost:9099',
        connectedOrigin: null,
      );
      expect(message, contains('production'));
      expect(message, contains('full page reload'));
      expect(message, isNot(contains('hot reload')));
    });

    test('names the origin this instance is actually on', () {
      expect(
        authEmulatorConnectTooLateMessage(
          appName: '[DEFAULT]',
          requestedOrigin: 'http://127.0.0.1:9100',
          connectedOrigin: 'http://localhost:9099',
        ),
        contains('http://localhost:9099'),
      );
    });
  });

  group('shouldThrowDebugEmulatorConnectFailure', () {
    test(
      'throws when persistence is on and this instance is on production',
      () {
        expect(
          shouldThrowDebugEmulatorConnectFailure(
            persistOrigin: true,
            requestedOrigin: 'http://localhost:9099',
            connectedOrigin: null,
          ),
          isTrue,
        );
      },
    );

    test(
      'throws when persistence is on and this instance is on a different emulator',
      () {
        expect(
          shouldThrowDebugEmulatorConnectFailure(
            persistOrigin: true,
            requestedOrigin: 'http://127.0.0.1:9100',
            connectedOrigin: 'http://localhost:9099',
          ),
          isTrue,
        );
      },
    );

    test('does not throw when persistence is off', () {
      expect(
        shouldThrowDebugEmulatorConnectFailure(
          persistOrigin: false,
          requestedOrigin: 'http://localhost:9099',
          connectedOrigin: null,
        ),
        isFalse,
      );
    });

    test('does not throw when this instance is already on that origin', () {
      expect(
        shouldThrowDebugEmulatorConnectFailure(
          persistOrigin: true,
          requestedOrigin: 'http://localhost:9099',
          connectedOrigin: 'http://localhost:9099',
        ),
        isFalse,
      );
    });
  });

  group('applyPersistedAuthEmulatorOrigin', () {
    late bool previous;

    setUp(() {
      previous = FirebaseAuthPlatform.persistWebEmulatorOrigin;
    });

    tearDown(() {
      FirebaseAuthPlatform.persistWebEmulatorOrigin = previous;
    });

    test('does not read storage or connect when persistence is off', () {
      FirebaseAuthPlatform.persistWebEmulatorOrigin = false;
      var reads = 0;
      var connects = 0;
      applyPersistedAuthEmulatorOrigin(
        appName: '[DEFAULT]',
        hostname: 'localhost',
        readLocal: (_) {
          reads++;
          return 'http://localhost:9099';
        },
        readSession: (_) {
          reads++;
          return null;
        },
        connect: (_) => connects++,
        connectedOrigin: () => null,
        rememberReached: (_) {},
        log: (_) {},
      );
      expect(reads, 0);
      expect(connects, 0);
    });

    test('connects a stored loopback origin when persistence is on', () {
      FirebaseAuthPlatform.persistWebEmulatorOrigin = true;
      String? connected;
      String? remembered;
      final logs = <String>[];
      applyPersistedAuthEmulatorOrigin(
        appName: '[DEFAULT]',
        hostname: '127.0.0.1',
        readLocal: (key) {
          expect(key, '[DEFAULT]-firebaseEmulatorOrigin');
          return 'http://localhost:9099';
        },
        readSession: (_) => null,
        connect: (origin) => connected = origin,
        connectedOrigin: () => connected,
        rememberReached: (origin) => remembered = origin,
        log: logs.add,
      );
      expect(connected, 'http://localhost:9099');
      expect(remembered, 'http://localhost:9099');
      expect(logs.single, contains('http://localhost:9099'));
      expect(logs.single, contains('emulator setting'));
    });

    test('does not connect a stored origin on a non-loopback host', () {
      FirebaseAuthPlatform.persistWebEmulatorOrigin = true;
      var connects = 0;
      applyPersistedAuthEmulatorOrigin(
        appName: '[DEFAULT]',
        hostname: 'example.com',
        readLocal: (_) => 'http://localhost:9099',
        readSession: (_) => null,
        connect: (_) => connects++,
        connectedOrigin: () => null,
        rememberReached: (_) {},
        log: (_) {},
      );
      expect(connects, 0);
    });

    test('logs a too-late connect and does not rethrow', () {
      FirebaseAuthPlatform.persistWebEmulatorOrigin = true;
      final logs = <String>[];
      var remembered = 0;
      applyPersistedAuthEmulatorOrigin(
        appName: '[DEFAULT]',
        hostname: 'localhost',
        readLocal: (_) => 'http://localhost:9099',
        readSession: (_) => null,
        connect: (_) => throw StateError('sooner'),
        connectedOrigin: () => 'http://127.0.0.1:9099',
        rememberReached: (_) => remembered++,
        log: logs.add,
      );
      expect(remembered, 0);
      expect(logs.single, contains('http://127.0.0.1:9099'));
    });

    test('rethrows a connect error that is not a too-late refusal', () {
      FirebaseAuthPlatform.persistWebEmulatorOrigin = true;
      expect(
        () => applyPersistedAuthEmulatorOrigin(
          appName: '[DEFAULT]',
          hostname: 'localhost',
          readLocal: (_) => 'http://localhost:9099',
          readSession: (_) => null,
          connect: (_) => throw StateError('blocked'),
          connectedOrigin: () => null,
          rememberReached: (_) {},
          log: (_) {},
        ),
        throwsStateError,
      );
    });
  });
}
