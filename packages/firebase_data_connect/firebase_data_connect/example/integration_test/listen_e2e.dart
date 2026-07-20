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
      testWidgets('should be able to gracefully cancel',
          (WidgetTester tester) async {
        final initialValue =
            await MoviesConnector.instance.listMovies().ref().execute();
        expect(initialValue.data.movies.length, 0,
            reason: 'Initial movie list should be empty');

        final Completer<void> isReady = Completer<void>();
        final Completer<bool> hasBeenListened = Completer<bool>();
        int count = 0;

        final listener1 = MoviesConnector.instance
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
        int listener2Count = 0;
        final listener2 = MoviesConnector.instance
            .listMovies()
            .ref()
            .subscribe()
            .listen((value) {
          listener2Count++;
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

        await MoviesConnector.instance.listMovies().ref().execute();

        // Wait for the listener to receive the movie update
        final bool hasListenerReceived = await hasBeenListened.future;

        // Cancel the listener and wait for it to finish
        await listener1.cancel();
        expect(hasListenerReceived, isTrue,
            reason: 'The stream should have emitted new data');
        // Create the movie
        await MoviesConnector.instance
            .createMovie(
              genre: 'Adventure',
              title: 'Raiders of the Lost Arc',
              releaseYear: 1999,
            )
            .rating(4.5)
            .ref()
            .execute();
        await Future.delayed(const Duration(seconds: 5));
        expect(count, equals(2));
        expect(listener2Count, equals(3));
        await listener2.cancel();
      });
    },
  );
}
