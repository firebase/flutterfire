// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:firebase_data_connect_example/generated/movies.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> deleteAllMovies() async {
  final value = await MoviesConnector.instance.listMovies().ref().execute();
  final result = value.data;
  for (var movie in result.movies) {
    await MoviesConnector.instance.deleteMovie(id: movie.id).ref().execute();
  }
}

void runQueryTests() {
  group(
    '$FirebaseDataConnect.instance query',
    () {
      setUp(() async {
        await deleteAllMovies();
      });

      testWidgets('can query', (WidgetTester tester) async {
        final value =
            await MoviesConnector.instance.listMovies().ref().execute();

        final result = value.data;
        expect(result.movies.length, 0);
      });

      testWidgets('can add a movie', (WidgetTester tester) async {
        MutationRef ref = MoviesConnector.instance
            .createMovie(
              genre: 'Action',
              title: 'The Matrix',
              releaseYear: 1999,
            )
            .rating(4.5)
            .ref();

        await ref.execute();

        final value =
            await MoviesConnector.instance.listMovies().ref().execute();
        final result = value.data;
        expect(result.movies.length, 1);
        expect(result.movies[0].title, 'The Matrix');
      });

      testWidgets('can add a director to a movie', (WidgetTester tester) async {
        MutationRef ref =
            MoviesConnector.instance.addPerson().name('Keanu Reeves').ref();

        await ref.execute();

        final personId =
            (await MoviesConnector.instance.listPersons().ref().execute())
                .data
                .people[0]
                .id;

        final value =
            await MoviesConnector.instance.listMovies().ref().execute();
        final result = value.data;
        expect(result.movies.length, 0);

        ref = MoviesConnector.instance
            .createMovie(
              genre: 'Action',
              title: 'The Matrix',
              releaseYear: 1999,
            )
            .rating(4.5)
            .ref();

        await ref.execute();

        final value2 =
            await MoviesConnector.instance.listMovies().ref().execute();
        final result2 = value2.data;
        expect(result2.movies.length, 1);

        final movieId = result2.movies[0].id;

        ref = MoviesConnector.instance
            .addDirectorToMovie()
            .movieId(movieId)
            .personId(AddDirectorToMovieVariablesPersonId(id: personId))
            .ref();

        await ref.execute();

        final value3 =
            await MoviesConnector.instance.listMovies().ref().execute();
        final result3 = value3.data;
        expect(result3.movies.length, 1);
        expect(result3.movies[0].directed_by.length, 1);
        expect(result3.movies[0].directed_by[0].name, 'Keanu Reeves');
      });

      testWidgets('can delete a movie', (WidgetTester tester) async {
        MutationRef ref = MoviesConnector.instance
            .createMovie(
              genre: 'Action',
              title: 'The Matrix',
              releaseYear: 1999,
            )
            .rating(4.5)
            .ref();

        await ref.execute();

        final value =
            await MoviesConnector.instance.listMovies().ref().execute();
        final result = value.data;
        expect(result.movies.length, 1);

        final movieId = result.movies[0].id;

        ref = MoviesConnector.instance.deleteMovie(id: movieId).ref();

        await ref.execute();

        final value2 =
            await MoviesConnector.instance.listMovies().ref().execute();
        final result2 = value2.data;
        expect(result2.movies.length, 0);
      });
    },
  );
}
