// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:drive/drive.dart' as drive;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_installations/firebase_app_installations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'firebase_config.dart';

void testsMain() {
  late FirebaseInstallations installations;

  setUpAll(() async {
    await Firebase.initializeApp(options: TestFirebaseConfig.platformOptions);
    installations = FirebaseInstallations.instance;
  });

  group('Installations ', () {
    test('.getId', () async {
      final id = await installations.getId();
      expect(id, isNotEmpty);
    });
    test('.delete', () async {
      final id = await installations.getId();

      // Wait a little so we don't get a delete-pending exception
      await Future.delayed(const Duration(seconds: 8));

      await installations.delete();

      // Wait a little so we don't get a delete-pending exception
      await Future.delayed(const Duration(seconds: 8));

      final newId = await installations.getId();
      expect(newId, isNot(equals(id)));
    });
    test('.getToken', () async {
      final token = await installations.getId();
      expect(token, isNotEmpty);
    });
  });
}

void main() => drive.main(testsMain);
