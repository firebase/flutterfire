// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:firebase_data_connect_example/generated/movies.dart';
import 'package:flutter/foundation.dart' show kIsWasm;
import 'package:flutter_test/flutter_test.dart';

import 'query_e2e.dart';

/// Subscription delivery over the multiplexed WebSocket is not stable under
/// dart2wasm: cancelling one listener does not reliably stop delivery to it,
/// and later subscriptions can then never receive a first event. The same
/// tests pass under dart2js. Skipped rather than retried so the suite stays
/// deterministic.
///
/// See https://github.com/firebase/flutterfire/issues/18518
const _wasmSkipReason =
    'Subscriptions over the multiplexed WebSocket are unstable under dart2wasm';

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

        final listener1Ready = Completer<void>();
        final listener2Ready = Completer<void>();
        final listener1ReceivedUpdate = Completer<void>();
        final listener2ReceivedUpdate = Completer<void>();

        int count1 = 0;
        int count2 = 0;

        final listener1 = MoviesConnector.instance
            .listMovies()
            .ref()
            .subscribe()
            .listen((value) {
          count1++;
          if (count1 == 1 && !listener1Ready.isCompleted) {
            listener1Ready.complete();
          } else if (count1 == 2 && !listener1ReceivedUpdate.isCompleted) {
            listener1ReceivedUpdate.complete();
          }
        });

        final listener2 = MoviesConnector.instance
            .listMovies()
            .ref()
            .subscribe()
            .listen((value) {
          count2++;
          if (count2 == 1 && !listener2Ready.isCompleted) {
            listener2Ready.complete();
          } else if (count2 == 3 && !listener2ReceivedUpdate.isCompleted) {
            listener2ReceivedUpdate.complete();
          }
        });

        try {
          // Wait for both listeners to be ready with initial emission
          await Future.wait([
            listener1Ready.future,
            listener2Ready.future,
          ]).timeout(_listenTimeout);

          // Create first movie
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

          // Wait for listener1 to receive the update
          await listener1ReceivedUpdate.future.timeout(_listenTimeout);

          // Cancel listener1
          await listener1.cancel();

          // Create second movie
          await MoviesConnector.instance
              .createMovie(
                genre: 'Adventure',
                title: 'Raiders of the Lost Arc',
                releaseYear: 1999,
              )
              .rating(4.5)
              .ref()
              .execute();

          await MoviesConnector.instance.listMovies().ref().execute();

          // Wait deterministically for listener2's 3rd emission
          await listener2ReceivedUpdate.future.timeout(_listenTimeout);

          expect(count1, equals(2),
              reason: 'Canceled listener should not receive further updates');
          expect(count2, equals(3),
              reason: 'Active listener should receive all updates');
        } finally {
          await listener1.cancel();
          await listener2.cancel();
        }
      });
    },
    skip: kIsWasm ? _wasmSkipReason : null,
  );
}
