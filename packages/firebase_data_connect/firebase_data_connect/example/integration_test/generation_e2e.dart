// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:firebase_data_connect_example/generated/movies.dart';
import 'package:flutter_test/flutter_test.dart';

void runGenerationTest() {
  group(
    '$FirebaseDataConnect generation',
    () {
      late FirebaseDataConnect fdc;

      setUpAll(() async {
        fdc = FirebaseDataConnect.instanceFor(
          connectorConfig: MoviesConnector.connectorConfig,
        );
      });

      testWidgets('should have generated correct MoviesConnector',
          (WidgetTester tester) async {
        final connector = MoviesConnector(dataConnect: fdc);
        expect(connector, isNotNull);
        expect(connector.addPerson, isNotNull);
        expect(connector.createMovie, isNotNull);
        expect(connector.listMovies, isNotNull);
        expect(connector.addDirectorToMovie, isNotNull);
      });

      testWidgets('should have generated correct MutationRef',
          (WidgetTester tester) async {
        final ref = MoviesConnector.instance
            .createMovie(
              genre: 'Action',
              title: 'The Matrix',
              releaseYear: 1999,
            )
            .rating(4.5);
        expect(ref, isNotNull);
        expect(ref.execute, isNotNull);
      });

      testWidgets('should have generated correct QueryRef',
          (WidgetTester tester) async {
        final ref = MoviesConnector.instance.listMovies().ref();
        expect(ref, isNotNull);
        expect(ref.execute, isNotNull);
      });

      testWidgets('should have generated correct MutationRef using name',
          (WidgetTester tester) async {
        final ref = MoviesConnector.instance.addPerson().name('Keanu Reeves');
        expect(ref, isNotNull);
        expect(ref.execute, isNotNull);
      });

      testWidgets('should have generated correct MutationRef using nested id',
          (WidgetTester tester) async {
        final ref = MoviesConnector.instance
            .addDirectorToMovie()
            .movieId('movieId')
            .personId(AddDirectorToMovieVariablesPersonId(id: 'personId'));
        expect(ref, isNotNull);
        expect(ref.execute, isNotNull);
      });

      testWidgets(
          'should populate only non-required fields with builder pattern',
          (WidgetTester tester) async {
        final movieBuilder = MoviesConnector.instance.createMovie(
          genre: 'Action',
          title: 'Inception',
          releaseYear: 2010,
        );

        movieBuilder.rating(4.8);

        final mutationRef = movieBuilder.ref();
        expect(mutationRef, isNotNull);
        expect(mutationRef.execute, isNotNull);
      });
    },
  );
}
