// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:firebase_data_connect_example/generated/movies.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> deleteAllMovies() async {
  final value = await MoviesConnector.instance.listMovies.ref().execute();
  final result = value.data;
  for (var movie in result.movies) {
    await MoviesConnector.instance.deleteMovie.ref(id: movie.id).execute();
  }
}

void runQueryTests() {
  group(
    '$FirebaseDataConnect.instance query',
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

      testWidgets('can query', (WidgetTester tester) async {
        final value = await MoviesConnector.instance.listMovies.ref().execute();

        final result = value.data;
        expect(result.movies.length, 0);
      });

      testWidgets('can add a movie and delete it', (WidgetTester tester) async {
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

      testWidgets('can add a person', (WidgetTester tester) async {
        MutationRef ref = MoviesConnector.instance.addPerson.ref(
          name: 'Keanu Reeves',
          addPersonVariables: AddPersonVariables(
            name: 'Keanu Reeves',
          ),
        );

        await ref.execute();

        final value = await MoviesConnector.instance.listMovies.ref().execute();
        final result = value.data;
        expect(result.movies.length, 1);
      });

      testWidgets('can add a director to a movie', (WidgetTester tester) async {
        MutationRef ref = MoviesConnector.instance.addPerson.ref(
          name: 'Keanu Reeves',
          addPersonVariables: AddPersonVariables(
            name: 'Keanu Reeves',
          ),
        );

        await ref.execute();

        final value = await MoviesConnector.instance.listMovies.ref().execute();
        final result = value.data;
        expect(result.movies.length, 1);

        final movieId = result.movies[0].id;

        ref = MoviesConnector.instance.addDirectorToMovie.ref(
          movieId: movieId,
          addDirectorToMovieVariables: AddDirectorToMovieVariables(
            personId: AddDirectorToMovieVariablesPersonId(id: 'personId'),
          ),
        );

        await ref.execute();

        final value2 =
            await MoviesConnector.instance.listMovies.ref().execute();
        final result2 = value2.data;
        expect(result2.movies.length, 1);
        expect(result2.movies[0].directed_by.length, 1);
      });

      testWidgets('can add a director to a movie using id',
          (WidgetTester tester) async {
        MutationRef ref = MoviesConnector.instance.addPerson.ref(
          name: 'Keanu Reeves',
          addPersonVariables: AddPersonVariables(
            name: 'Keanu Reeves',
          ),
        );

        await ref.execute();

        final value = await MoviesConnector.instance.listMovies.ref().execute();
        final result = value.data;
        expect(result.movies.length, 1);

        final movieId = result.movies[0].id;

        ref = MoviesConnector.instance.addDirectorToMovie.ref(
          movieId: movieId,
          addDirectorToMovieVariables: AddDirectorToMovieVariables(
            personId: AddDirectorToMovieVariablesPersonId(id: 'personId'),
          ),
        );

        await ref.execute();

        final value2 =
            await MoviesConnector.instance.listMovies.ref().execute();
        final result2 = value2.data;
        expect(result2.movies.length, 1);
        expect(result2.movies[0].directed_by.length, 1);
      });

      testWidgets('can delete a movie', (WidgetTester tester) async {
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

        final movieId = result.movies[0].id;

        ref = MoviesConnector.instance.deleteMovie.ref(id: movieId);

        await ref.execute();

        final value2 =
            await MoviesConnector.instance.listMovies.ref().execute();
        final result2 = value2.data;
        expect(result2.movies.length, 0);
      });
    },
  );
}
