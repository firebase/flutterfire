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

      testWidgets('can add a movie', (WidgetTester tester) async {
        MutationRef ref = MoviesConnector.instance.createMovie.ref(
          genre: 'Action',
          title: 'The Matrix',
          releaseYear: 1999,
          rating: 4.5,
        );

        await ref.execute();

        final value = await MoviesConnector.instance.listMovies.ref().execute();
        final result = value.data;
        expect(result.movies.length, 1);
        expect(result.movies[0].title, 'The Matrix');
      });
    },
  );
}
