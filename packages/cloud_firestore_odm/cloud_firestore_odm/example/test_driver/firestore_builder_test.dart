// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_odm/cloud_firestore_odm.dart';
import 'package:cloud_firestore_odm_example/movie.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'common.dart';

void main() {
  group('FirestoreBuilder', () {
    setUpAll(() async {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyAHAsf51D0A407EklG1bs-5wA7EbyfNFg0',
          appId: '1:448618578101:ios:3a3c8ae9cb0b6408ac3efc',
          messagingSenderId: '448618578101',
          projectId: 'react-native-firebase-testing',
          authDomain: 'react-native-firebase-testing.firebaseapp.com',
          iosClientId:
              '448618578101-m53gtqfnqipj12pts10590l37npccd2r.apps.googleusercontent.com',
        ),
      );
    });

    Widget buildMovieList(MovieQuery query) {
      return MaterialApp(
        home: Scaffold(
          body: FirestoreBuilder<MovieQuerySnapshot>(
            ref: query,
            builder: (context, snapshot, _) {
              if (snapshot.hasError) return const Text('error');
              if (!snapshot.hasData) return const Text('loading');

              return ListView(
                children: [
                  for (final doc in snapshot.requireData.docs)
                    Text(doc.data.title),
                ],
              );
            },
          ),
        ),
      );
    }

    Widget buildMovie(MovieDocumentReference doc) {
      return MaterialApp(
        home: Scaffold(
          body: FirestoreBuilder<MovieDocumentSnapshot>(
            ref: doc,
            builder: (context, snapshot, _) {
              if (snapshot.hasError) return const Text('error');
              if (!snapshot.hasData) return const Text('loading');

              return Text(snapshot.requireData.data?.title ?? '<none>');
            },
          ),
        ),
      );
    }

    group('$FirestoreBuilder', () {
      testWidgets('listens to documents', (tester) async {
        final collection = await initializeTest(MovieCollectionReference());

        final doc = collection.doc('123');

        await tester.pumpWidget(buildMovie(doc));

        expect(find.text('loading'), findsOneWidget);

        await tester.pumpAndSettle();

        expect(find.text('<none>'), findsOneWidget);

        await doc.set(createMovie(title: 'Foo'));
        await tester.pumpAndSettle();

        expect(find.text('Foo'), findsOneWidget);
      });

      testWidgets('emits errored snapshot when failed to decode a value',
          (tester) async {
        final collection = await initializeTest(MovieCollectionReference());

        await FirebaseFirestore.instance
            .collection(collection.path)
            .doc('123')
            .set(<String, Object?>{'value': 42});

        await tester.pumpWidget(buildMovie(collection.doc('123')));

        expect(find.text('loading'), findsOneWidget);

        await tester.pumpAndSettle();

        expect(find.text('error'), findsOneWidget);

        await collection.doc('123').set(createMovie(title: 'title'));

        await tester.pumpAndSettle();

        expect(find.text('title'), findsOneWidget);
      });

      testWidgets('listens to queries', (tester) async {
        final collection = await initializeTest(MovieCollectionReference());

        await collection.add(createMovie(title: 'A'));
        final bar = await collection.add(createMovie(title: 'B'));
        final barSnapshot = await bar.get();

        await tester.pumpWidget(
          buildMovieList(
            collection.orderByTitle(startAtDocument: barSnapshot),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('loading'), findsNothing);
        expect(find.text('error'), findsNothing);
        expect(find.text('A'), findsNothing);
        expect(find.text('B'), findsOneWidget);
        expect(find.text('C'), findsNothing);

        await collection.add(createMovie(title: 'C'));

        await tester.pumpAndSettle();

        expect(find.text('A'), findsNothing);
        expect(find.text('B'), findsOneWidget);
        expect(find.text('C'), findsOneWidget);
      });

      testWidgets('listens to a collection', (tester) async {
        final collection = await initializeTest(MovieCollectionReference());

        await collection.add(createMovie(title: 'A'));

        await tester.pumpWidget(
          buildMovieList(collection),
        );

        expect(find.text('loading'), findsOneWidget);

        await tester.pumpAndSettle();

        expect(find.text('A'), findsOneWidget);
        expect(find.text('B'), findsNothing);

        await collection.add(createMovie(title: 'B'));

        await tester.pump();

        expect(find.text('A'), findsOneWidget);
        expect(find.text('B'), findsOneWidget);
      });
      testWidgets(
          'does not go back to loading if rebuilding the widget with the same query',
          (tester) async {
        final collection = await initializeTest(MovieCollectionReference());

        await collection.add(createMovie(title: 'A'));
        await collection.add(createMovie(title: 'B'));

        await tester.pumpWidget(
          buildMovieList(collection.orderByTitle().limit(1)),
        );

        expect(find.text('loading'), findsOneWidget);

        await tester.pumpAndSettle();

        expect(find.text('A'), findsOneWidget);
        expect(find.text('B'), findsNothing);

        await tester.pumpWidget(
          buildMovieList(collection.orderByTitle().limit(1)),
        );

        expect(find.text('A'), findsOneWidget);
        expect(find.text('B'), findsNothing);
      });
    });
  });
}
