// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_app_installations/firebase_app_installations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_app_installations_example/firebase_options.dart';

// Was imported from the `tests` app's aggregated `e2e_test.dart` before this
// suite moved into the example; it is the only thing this file needed from
// there.
// Github Actions environment variable
// ignore: do_not_use_environment
final isCI = const String.fromEnvironment('CI').isNotEmpty;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group(
    'firebase_app_installations',
    () {
      setUpAll(() async {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        if (defaultTargetPlatform == TargetPlatform.android) {
          // Android Installations can deadlock if token/id APIs race native
          // heartbeat initialization immediately after manual app init.
          await Future<void>.delayed(const Duration(seconds: 2));
        }
      });

      test(
        '.getId',
        () async {
          final id = await FirebaseInstallations.instance.getId();
          expect(id, isNotEmpty);
          // macOS skipped because it needs keychain sharing entitlement. See: https://github.com/firebase/flutterfire/issues/9538
        },
        skip: defaultTargetPlatform == TargetPlatform.macOS,
      );

      test(
        'running get id in parallel',
        () async {
          final ids = await Future.wait([
            FirebaseInstallations.instance.getId(),
            FirebaseInstallations.instance.getId(),
            FirebaseInstallations.instance.getId(),
            FirebaseInstallations.instance.getId(),
            FirebaseInstallations.instance.getId(),
          ]);
          expect(ids, isNotNull);
        },
        skip: defaultTargetPlatform == TargetPlatform.macOS && isCI,
      );

      test(
        '.getToken',
        () async {
          final token = await FirebaseInstallations.instance.getToken();
          expect(token, isNotEmpty);
          // macOS skipped because it needs keychain sharing entitlement. See: https://github.com/firebase/flutterfire/issues/9538
        },
        skip: defaultTargetPlatform == TargetPlatform.macOS,
      );

      test(
        '.delete',
        () async {
          final id = await FirebaseInstallations.instance.getId();

          // Retry delete in case of delete-pending state
          for (var attempt = 0; attempt < 5; attempt++) {
            try {
              await FirebaseInstallations.instance.delete();
              break;
            } catch (e) {
              if (attempt == 4) rethrow;
              await Future.delayed(const Duration(seconds: 2));
            }
          }

          // Retry getId in case of delete-pending state
          String? newId;
          for (var attempt = 0; attempt < 5; attempt++) {
            try {
              newId = await FirebaseInstallations.instance.getId();
              break;
            } catch (e) {
              if (attempt == 4) rethrow;
              await Future.delayed(const Duration(seconds: 2));
            }
          }
          expect(newId, isNot(equals(id)));
          // macOS skipped because it needs keychain sharing entitlement. See: https://github.com/firebase/flutterfire/issues/9538
        },
        skip: defaultTargetPlatform == TargetPlatform.macOS,
      );
    },
  );
}
