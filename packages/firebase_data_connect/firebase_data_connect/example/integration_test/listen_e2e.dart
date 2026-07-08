// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:firebase_data_connect_example/generated/movies.dart';
import 'package:flutter_test/flutter_test.dart';

import 'query_e2e.dart';

const _listenTimeout = Duration(seconds: 30);

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

        final initialMovies = Completer<List<ListMoviesMovies>>();
        final updatedMovies = Completer<List<ListMoviesMovies>>();

        final listener = MoviesConnector.instance
            .listMovies()
            .ref()
            .subscribe()
            .listen((value) {
          final movies = value.data.movies;

          if (!initialMovies.isCompleted && movies.isEmpty) {
            initialMovies.complete(movies);
          } else if (!updatedMovies.isCompleted &&
              movies.length == 1 &&
              movies.single.title == 'The Matrix') {
            updatedMovies.complete(movies);
          }
        });

        try {
          // Wait for the listener to be ready
          final initial = await initialMovies.future.timeout(_listenTimeout);
          expect(initial, isEmpty,
              reason: 'First emission should contain an empty list');

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

          await MoviesConnector.instance
              .listMovies()
              .ref()
              .execute(fetchPolicy: QueryFetchPolicy.serverOnly);

          // Wait for the listener to receive the movie update
          final movies = await updatedMovies.future.timeout(_listenTimeout);

          expect(movies, hasLength(1),
              reason: 'Second emission should contain one movie');
          expect(movies.single.title, 'The Matrix',
              reason: 'The movie should be The Matrix');
        } finally {
          // Cancel the listener and wait for it to finish
          await listener.cancel();
        }
      });
    },
  );
}
