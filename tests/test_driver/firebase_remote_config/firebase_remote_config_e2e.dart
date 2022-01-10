// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

import 'package:drive/drive.dart';
import '../firebase_default_options.dart';

void setupTests() {
  group(
    'firebase_remote_config',
    () {
      setUpAll(() async {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        await RemoteConfig.instance.setConfigSettings(
          RemoteConfigSettings(
            fetchTimeout: const Duration(seconds: 8),
            minimumFetchInterval: Duration.zero,
          ),
        );
        await RemoteConfig.instance.setDefaults(<String, dynamic>{
          'hello': 'default hello',
        });
        await RemoteConfig.instance.ensureInitialized();
      });

      test('fetch', () async {
        final mark = DateTime.now();
        expect(RemoteConfig.instance.lastFetchTime.isBefore(mark), true);
        await RemoteConfig.instance.fetchAndActivate();
        expect(
          RemoteConfig.instance.lastFetchStatus,
          RemoteConfigFetchStatus.success,
        );
        expect(RemoteConfig.instance.lastFetchTime.isAfter(mark), true);
        expect(RemoteConfig.instance.getString('string'), 'flutterfire');
        expect(RemoteConfig.instance.getBool('bool'), isTrue);
        expect(RemoteConfig.instance.getInt('int'), 123);
        expect(RemoteConfig.instance.getDouble('double'), 123.456);
        expect(
          RemoteConfig.instance.getValue('string').source,
          ValueSource.valueRemote,
        );

        expect(RemoteConfig.instance.getString('hello'), 'default hello');
        expect(
          RemoteConfig.instance.getValue('hello').source,
          ValueSource.valueDefault,
        );

        expect(RemoteConfig.instance.getInt('nonexisting'), 0);

        expect(
          RemoteConfig.instance.getValue('nonexisting').source,
          ValueSource.valueStatic,
        );
      });

      test('settings', () async {
        expect(
          RemoteConfig.instance.settings.fetchTimeout,
          const Duration(seconds: 8),
        );
        expect(
          RemoteConfig.instance.settings.minimumFetchInterval,
          Duration.zero,
        );
        await RemoteConfig.instance.setConfigSettings(
          RemoteConfigSettings(
            fetchTimeout: Duration.zero,
            minimumFetchInterval: const Duration(seconds: 88),
          ),
        );
        expect(
          RemoteConfig.instance.settings.fetchTimeout,
          const Duration(seconds: 60),
        );
        expect(
          RemoteConfig.instance.settings.minimumFetchInterval,
          const Duration(seconds: 88),
        );
        await RemoteConfig.instance.setConfigSettings(
          RemoteConfigSettings(
            fetchTimeout: const Duration(seconds: 10),
            minimumFetchInterval: Duration.zero,
          ),
        );
        expect(
          RemoteConfig.instance.settings.fetchTimeout,
          const Duration(seconds: 10),
        );
        expect(
          RemoteConfig.instance.settings.minimumFetchInterval,
          Duration.zero,
        );
      });
    },
  );
}
