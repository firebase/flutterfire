// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tests/firebase_options.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group(
    'firebase_remote_config',
    () {
      setUpAll(() async {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        await FirebaseRemoteConfig.instance.setConfigSettings(
          RemoteConfigSettings(
            fetchTimeout: const Duration(seconds: 8),
            minimumFetchInterval: Duration.zero,
          ),
        );
        await FirebaseRemoteConfig.instance.setDefaults(<String, dynamic>{
          'hello': 'default hello',
        });
        await FirebaseRemoteConfig.instance.ensureInitialized();
      });

      test(
        'fetch',
        () async {
          final mark = DateTime.now();
          expect(
            FirebaseRemoteConfig.instance.lastFetchTime.isBefore(mark),
            true,
          );

          await FirebaseRemoteConfig.instance.fetchAndActivate();

          expect(
            FirebaseRemoteConfig.instance.lastFetchStatus,
            RemoteConfigFetchStatus.success,
          );
          expect(
            FirebaseRemoteConfig.instance.lastFetchTime.isAfter(mark),
            true,
          );
          expect(
            FirebaseRemoteConfig.instance.getString('string'),
            'flutterfire',
          );
          expect(FirebaseRemoteConfig.instance.getBool('bool'), isTrue);
          expect(FirebaseRemoteConfig.instance.getInt('int'), 123);
          expect(FirebaseRemoteConfig.instance.getDouble('double'), 123.456);
          expect(
            FirebaseRemoteConfig.instance.getValue('string').source,
            ValueSource.valueRemote,
          );

          expect(
            FirebaseRemoteConfig.instance.getString('hello'),
            'default hello',
          );
          expect(
            FirebaseRemoteConfig.instance.getValue('hello').source,
            ValueSource.valueDefault,
          );

          expect(FirebaseRemoteConfig.instance.getInt('nonexisting'), 0);

          expect(
            FirebaseRemoteConfig.instance.getValue('nonexisting').source,
            ValueSource.valueStatic,
          );
        },
        // iOS v9.2.0 hangs on ci if `fetchAndActivate()` is used, but works locally.
        // macOS skipped because it needs keychain sharing entitlement. See: https://github.com/firebase/flutterfire/issues/9538
        skip: defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS,
      );

      test('settings', () async {
        expect(
          FirebaseRemoteConfig.instance.settings.fetchTimeout,
          const Duration(seconds: 8),
        );
        expect(
          FirebaseRemoteConfig.instance.settings.minimumFetchInterval,
          Duration.zero,
        );
        await FirebaseRemoteConfig.instance.setConfigSettings(
          RemoteConfigSettings(
            fetchTimeout: Duration.zero,
            minimumFetchInterval: const Duration(seconds: 88),
          ),
        );
        expect(
          FirebaseRemoteConfig.instance.settings.fetchTimeout,
          const Duration(seconds: 60),
        );
        expect(
          FirebaseRemoteConfig.instance.settings.minimumFetchInterval,
          const Duration(seconds: 88),
        );
        await FirebaseRemoteConfig.instance.setConfigSettings(
          RemoteConfigSettings(
            fetchTimeout: const Duration(seconds: 10),
            minimumFetchInterval: Duration.zero,
          ),
        );
        expect(
          FirebaseRemoteConfig.instance.settings.fetchTimeout,
          const Duration(seconds: 10),
        );
        expect(
          FirebaseRemoteConfig.instance.settings.minimumFetchInterval,
          Duration.zero,
        );
      });
    },
  );
}
