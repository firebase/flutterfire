// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core_interface/firebase_core_interface.dart';
import 'package:test/test.dart';

void main() {
  group('core exceptions', () {
    test('use the core plugin and their codes', () {
      expect(noAppExists('foo').code, 'no-app');
      expect(noAppExists('foo').message, contains("'foo'"));
      expect(duplicateApp('foo').code, 'duplicate-app');
      expect(coreNotInitialized().code, 'not-initialized');
      expect(noDefaultAppInitialization().code, 'unknown');
      expect(noDefaultAppDelete().code, 'unknown');

      for (final e in [
        noAppExists('foo'),
        duplicateApp('foo'),
        coreNotInitialized(),
        noDefaultAppInitialization(),
        noDefaultAppDelete(),
      ]) {
        expect(e.plugin, 'core');
      }
    });

    test('name the default app', () {
      expect(noDefaultAppInitialization().message, contains('[DEFAULT]'));
      expect(defaultFirebaseAppName, '[DEFAULT]');
    });
  });
}
