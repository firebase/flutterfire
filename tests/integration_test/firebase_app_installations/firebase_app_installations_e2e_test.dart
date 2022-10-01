// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_app_installations/firebase_app_installations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tests/firebase_options.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group(
    'firebase_app_installations',
    () {
      setUpAll(() async {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
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
        '.delete',
        () async {
          final id = await FirebaseInstallations.instance.getId();

          // Wait a little so we don't get a delete-pending exception
          await Future.delayed(const Duration(seconds: 8));

          await FirebaseInstallations.instance.delete();

          // Wait a little so we don't get a delete-pending exception
          await Future.delayed(const Duration(seconds: 8));

          final newId = await FirebaseInstallations.instance.getId();
          expect(newId, isNot(equals(id)));
          // macOS skipped because it needs keychain sharing entitlement. See: https://github.com/firebase/flutterfire/issues/9538
        },
        skip: defaultTargetPlatform == TargetPlatform.macOS,
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
    },
  );
}
