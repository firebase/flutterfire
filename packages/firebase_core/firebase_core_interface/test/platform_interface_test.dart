// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core_interface/firebase_core_interface.dart';
import 'package:test/test.dart';

void main() {
  // `FirebasePlatform.instance` cannot be reset, so these tests run in order:
  // nothing registered, then the fallback, then a registered implementation.
  group('$FirebasePlatform.instance', () {
    test('throws a StateError when nothing is registered', () {
      expect(() => FirebasePlatform.instance, throwsStateError);
    });

    test('rejects a fallback that implements FirebasePlatform', () {
      FirebasePlatform.fallbackInstanceFactory = ImplementsFirebasePlatform.new;
      expect(() => FirebasePlatform.instance, throwsA(isA<AssertionError>()));
    });

    test('creates the fallback once when nothing is registered', () {
      var created = 0;
      FirebasePlatform.fallbackInstanceFactory = () {
        created++;
        return ExtendsFirebasePlatform();
      };

      final instance = FirebasePlatform.instance;
      expect(instance, isA<ExtendsFirebasePlatform>());
      expect(FirebasePlatform.instance, same(instance));
      expect(created, 1);
    });

    test('returns the registered implementation over the fallback', () {
      final registered = ExtendsFirebasePlatform();
      FirebasePlatform.instance = registered;
      expect(FirebasePlatform.instance, same(registered));
    });
  });

  group('$FirebasePlugin', () {
    tearDown(() => FirebasePlugin.removeConstantsForApp('app'));

    test('returns the constants stored for its app and plugin', () {
      FirebasePlugin.setConstantsForApp('app', {
        'plugins.flutter.io/test': {'enabled': true},
      });

      expect(TestFirebasePlugin('app').pluginConstants, {'enabled': true});
      expect(TestFirebasePlugin('other').pluginConstants, isEmpty);
    });

    test('returns no constants once they are removed', () {
      FirebasePlugin.setConstantsForApp('app', {
        'plugins.flutter.io/test': {'enabled': true},
      });
      FirebasePlugin.removeConstantsForApp('app');

      expect(TestFirebasePlugin('app').pluginConstants, isEmpty);
    });
  });
}

class ExtendsFirebasePlatform extends FirebasePlatform {}

class ImplementsFirebasePlatform implements FirebasePlatform {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class TestFirebasePlugin extends FirebasePlugin {
  TestFirebasePlugin(String appName)
    : super(appName, 'plugins.flutter.io/test');
}
