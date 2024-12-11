// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void runSettingsTest() {
  group(
    '$Settings',
    () {
      late FirebaseFirestore firestore;

      setUpAll(() async {
        firestore = FirebaseFirestore.instance;
      });

      Future<Settings> initializeTest() async {
        Settings firestoreSettings = const Settings(
          persistenceEnabled: false,
          webExperimentalForceLongPolling: true,
          webExperimentalAutoDetectLongPolling: true,
          webExperimentalLongPollingOptions: WebExperimentalLongPollingOptions(
            timeoutDuration: Duration(seconds: 15),
          ),
        );

        return firestore.settings = firestoreSettings;
      }

      test('checks if long polling settings were applied', () async {
        Settings settings = await initializeTest();

        expect(settings.webExperimentalForceLongPolling, true);

        expect(settings.webExperimentalAutoDetectLongPolling, true);

        expect(
          settings.webExperimentalLongPollingOptions,
          settings.webExperimentalLongPollingOptions,
        );
      });
    },
  );
}
