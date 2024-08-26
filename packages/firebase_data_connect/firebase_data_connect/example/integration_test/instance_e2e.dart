// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:firebase_data_connect_example/generated/movies.dart';
import 'package:flutter_test/flutter_test.dart';

void runInstanceTests() {
  group(
    '$FirebaseDataConnect.instance',
    () {
      late FirebaseDataConnect fdc;
      late FirebaseApp app;

      setUpAll(() async {
        app = Firebase.app();
        fdc = FirebaseDataConnect.instanceFor(
          app: app,
          connectorConfig: MoviesConnector.connectorConfig,
        );
      });

      testWidgets('can instantiate', (WidgetTester tester) async {
        expect(fdc, isNotNull);
      });

      testWidgets('can access app', (WidgetTester tester) async {
        expect(fdc.app = app, isTrue);
      });
    },
  );
}
