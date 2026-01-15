// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:firebase_data_connect_example/generated/movies.dart';
import 'package:flutter_test/flutter_test.dart';

import 'query_e2e.dart';

void runListenTests() {
  group(
    '$FirebaseDataConnect.instance listen',
    () {
      setUp(() async {
        await deleteAllMovies();
      });

      testWidgets('should be able to listen to the list of movies',
          (WidgetTester tester) async {
        final initialValue =
            await MoviesConnector.instance.listMovies().ref().execute();
        expect(initialValue.data.movies.length, 0,
            reason: 'Initial movie list should be empty');

        final Completer<void> isReady = Completer<void>();
        final Completer<bool> hasBeenListened = Completer<bool>();
        int count = 0;

        final listener = MoviesConnector.instance
            .listMovies()
            .ref()
            .subscribe()
            .listen((value) {
          final movies = value.data.movies;

          if (count == 0) {
            expect(movies.length, 0,
                reason: 'First emission should contain an empty list');
            isReady.complete();
          } else {
            expect(movies.length, 1,
                reason: 'Second emission should contain one movie');
            expect(movies[0].title, 'The Matrix',
                reason: 'The movie should be The Matrix');
            hasBeenListened.complete(true);
          }
          count++;
        });

        // Wait for the listener to be ready
        await isReady.future;

        // Create the movie
        await MoviesConnector.instance
            .createMovie(
              genre: 'Action',
              title: 'The Matrix',
              releaseYear: 1999,
            )
            .rating(4.5)
            .ref()
            .execute();

        await MoviesConnector.instance.listMovies().ref().execute(fetchPolicy: QueryFetchPolicy.serverOnly);

        // Wait for the listener to receive the movie update
        final bool hasListenerReceived = await hasBeenListened.future;

        // Cancel the listener and wait for it to finish
        await listener.cancel();

        expect(hasListenerReceived, isTrue,
            reason: 'The stream should have emitted new data');
      });
    },
  );
}
