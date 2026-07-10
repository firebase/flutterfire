// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:firebase_data_connect_example/generated/movies.dart';
import 'package:flutter_test/flutter_test.dart';

import 'query_e2e.dart'; // For deleteAllMovies

void runCacheTests() {
  group(
    '$FirebaseDataConnect cache',
    () {
      setUp(() async {
        // Enable cache with memory storage and a large TTL for testing.
        final dataConnect = MoviesConnector.instance.dataConnect;
        dataConnect.cacheSettings = CacheSettings(
          storage: CacheStorage.memory,
          maxAge: const Duration(minutes: 5),
        );
        // Re-apply emulator to force cache manager recreation with new settings
        dataConnect.useDataConnectEmulator('127.0.0.1', 9399);

        await deleteAllMovies();
      });

      testWidgets('test cache flow: serverOnly, cacheOnly, preferCache',
          (WidgetTester tester) async {
        final moviesConnector = MoviesConnector.instance;

        // 1. Initial query with preferCache should result in server hit because cache is empty.
        final res1 = await moviesConnector.listMovies().ref().execute(
              fetchPolicy: QueryFetchPolicy.preferCache,
            );
        expect(res1.source, DataSource.server);
        expect(res1.data.movies, isEmpty);

        // 2. Second query with preferCache should result in cache hit.
        final res2 = await moviesConnector.listMovies().ref().execute(
              fetchPolicy: QueryFetchPolicy.preferCache,
            );
        expect(res2.source, DataSource.cache);
        expect(res2.data.movies, isEmpty);

        // 3. Mutation to add a movie. This goes to server.
        await moviesConnector
            .createMovie(
              genre: 'Sci-Fi',
              title: 'Inception',
              releaseYear: 2010,
            )
            .ref()
            .execute();

        // 4. Query with cacheOnly should still return empty list (cache hit, stale data).
        final res3 = await moviesConnector.listMovies().ref().execute(
              fetchPolicy: QueryFetchPolicy.cacheOnly,
            );
        expect(res3.source, DataSource.cache);
        expect(res3.data.movies, isEmpty);

        // 5. Query with serverOnly should return the new movie (server hit) and update cache.
        final res4 = await moviesConnector.listMovies().ref().execute(
              fetchPolicy: QueryFetchPolicy.serverOnly,
            );
        expect(res4.source, DataSource.server);
        expect(res4.data.movies.length, 1);
        expect(res4.data.movies[0].title, 'Inception');

        // 6. Query with cacheOnly should now return the new movie (cache hit).
        final res5 = await moviesConnector.listMovies().ref().execute(
              fetchPolicy: QueryFetchPolicy.cacheOnly,
            );
        expect(res5.source, DataSource.cache);
        expect(res5.data.movies.length, 1);
        expect(res5.data.movies[0].title, 'Inception');
      });
    },
  );
}
