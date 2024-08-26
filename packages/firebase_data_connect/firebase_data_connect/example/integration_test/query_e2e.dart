// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:firebase_data_connect_example/generated/movies.dart';
import 'package:flutter_test/flutter_test.dart';

void runQueryTests() {
  group(
    '$FirebaseDataConnect.instance query',
    () {
      late FirebaseDataConnect fdc;

      setUpAll(() async {
        fdc = FirebaseDataConnect.instanceFor(
          connectorConfig: MoviesConnector.connectorConfig,
        );
      });

      testWidgets('can query', (WidgetTester tester) async {
        final value = await MoviesConnector.instance.listMovies.ref().execute();

        final result = value.data;
        expect(result.movies.length, 0);
      });
    },
  );
}
