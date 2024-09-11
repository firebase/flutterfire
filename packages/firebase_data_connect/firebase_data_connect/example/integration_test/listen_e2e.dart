// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:firebase_data_connect_example/generated/movies.dart';
import 'package:flutter_test/flutter_test.dart';

import 'query_e2e.dart';

void runListenTests() {
  group(
    '$FirebaseDataConnect.instance listen',
    () {
      // ignore: unused_local_variable
      late FirebaseDataConnect fdc;

      setUpAll(() async {
        fdc = FirebaseDataConnect.instanceFor(
          connectorConfig: MoviesConnector.connectorConfig,
        );
      });

      setUp(() async {
        await deleteAllMovies();
      });

      testWidgets('should be able to listen to the list of movies',
          (WidgetTester tester) async {
        final value = await MoviesConnector.instance.listMovies.ref().execute();

        final result = value.data;
        expect(result.movies.length, 0);

        bool hasBeenListened = false;
        int count = 0;

        final listener = MoviesConnector.instance.listMovies
            .ref()
            .subscribe()
            .listen((value) {
          if (count == 0) {
            final result = value.data;
            expect(result.movies.length, 0);
          } else {
            final result = value.data;
            expect(result.movies.length, 1);
            expect(result.movies[0].title, 'The Matrix');
            hasBeenListened = true;
          }
          count++;
        });

        MutationRef ref = MoviesConnector.instance.createMovie.ref(
          genre: 'Action',
          title: 'The Matrix',
          releaseYear: 1999,
          rating: 4.5,
        );

        await ref.execute();

        QueryRef ref2 = MoviesConnector.instance.listMovies.ref();
        await ref2.execute();

        await Future.delayed(const Duration(seconds: 1));

        listener.cancel();

        expect(hasBeenListened, true);
      });
    },
  );
}
