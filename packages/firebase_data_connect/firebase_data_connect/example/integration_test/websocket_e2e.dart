// Copyright 2026 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';

import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:firebase_data_connect_example/generated/movies.dart';
import 'package:flutter_test/flutter_test.dart';

import 'query_e2e.dart'; // For deleteAllMovies

void runWebSocketTests() {
  group(
    '$FirebaseDataConnect WebSocketTransport',
    () {
      setUp(() async {
        await deleteAllMovies();
      });

      testWidgets('should support multiplexing multiple subscriptions',
          (WidgetTester tester) async {
        final Completer<void> ready1 = Completer<void>();
        final Completer<void> ready2 = Completer<void>();
        final Completer<void> update1 = Completer<void>();
        final Completer<void> update2 = Completer<void>();

        int count1 = 0;
        int count2 = 0;

        final sub1 = MoviesConnector.instance
            .listMoviesByPartialTitle(input: 'Matrix')
            .ref()
            .subscribe()
            .listen((value) {
          if (count1 == 0) {
            ready1.complete();
          } else {
            update1.complete();
          }
          count1++;
        });

        final sub2 = MoviesConnector.instance
            .listMoviesByPartialTitle(input: 'Titan')
            .ref()
            .subscribe()
            .listen((value) {
          if (count2 == 0) {
            ready2.complete();
          } else {
            update2.complete();
          }
          count2++;
        });

        // Wait for both to be ready
        await ready1.future;
        await ready2.future;

        // Create movies
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
            .createMovie(
              genre: 'Drama',
              title: 'Titanic',
              releaseYear: 1997,
            )
            .rating(4.8)
            .ref()
            .execute();

        // Wait for updates
        await update1.future;
        await update2.future;

        await sub1.cancel();
        await sub2.cancel();
      });

      testWidgets(
          'should support unary operations over WebSocket when connected',
          (WidgetTester tester) async {
        final Completer<void> isReady = Completer<void>();
        int count = 0;

        // Start a subscription to ensure WebSocket is connected
        final sub = MoviesConnector.instance
            .listMovies()
            .ref()
            .subscribe()
            .listen((value) {
          if (count == 0) {
            isReady.complete();
          }
          count++;
        });

        await isReady.future;

        // Now perform a query, which should go over WebSocket if connected
        final result =
            await MoviesConnector.instance.listMovies().ref().execute();
        expect(result.data.movies.length, 0);

        // Perform a mutation
        await MoviesConnector.instance
            .createMovie(
              genre: 'Action',
              title: 'Inception',
              releaseYear: 2010,
            )
            .rating(4.9)
            .ref()
            .execute();

        // Verify update via query
        final result2 =
            await MoviesConnector.instance.listMovies().ref().execute();
        expect(result2.data.movies.length, 1);
        expect(result2.data.movies[0].title, 'Inception');

        await sub.cancel();
      });

      testWidgets('should stop receiving events after cancel',
          (WidgetTester tester) async {
        final Completer<void> isReady = Completer<void>();
        final Completer<void> receivedUpdate = Completer<void>();
        int count = 0;

        final sub = MoviesConnector.instance
            .listMovies()
            .ref()
            .subscribe()
            .listen((value) {
          if (count == 0) {
            isReady.complete();
          } else {
            receivedUpdate.complete();
          }
          count++;
        });

        await isReady.future;

        // Cancel the subscription
        await sub.cancel();

        // Create a movie
        await MoviesConnector.instance
            .createMovie(
              genre: 'Action',
              title: 'Avatar',
              releaseYear: 2009,
            )
            .rating(4.7)
            .ref()
            .execute();

        // Wait a bit to ensure no event is received
        bool received = true;
        try {
          await receivedUpdate.future.timeout(const Duration(seconds: 2));
        } on TimeoutException {
          received = false;
        }
        expect(received, isFalse,
            reason: 'Should not receive events after cancel');
      });
    },
  );
}
