// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_odm_example/integration/named_query.dart';
import 'package:cloud_firestore_odm_example/integration/query.dart';
import 'package:cloud_firestore_odm_example/movie.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'common.dart';

void main() {
  group('QueryReference', () {
    late FirebaseFirestore customFirestore;

    setUpAll(() async {
      customFirestore = FirebaseFirestore.instanceFor(
        app: await Firebase.initializeApp(
          name: 'custom-query-app',
          options: FirebaseOptions(
            apiKey: Firebase.app().options.apiKey,
            appId: Firebase.app().options.appId,
            messagingSenderId: Firebase.app().options.messagingSenderId,
            projectId: Firebase.app().options.projectId,
          ),
        ),
      );
    });

    group('root query', () {
      test('overrides ==', () {
        expect(
          MovieCollectionReference().limit(1),
          MovieCollectionReference(FirebaseFirestore.instance).limit(1),
        );
        expect(
          MovieCollectionReference().limit(1),
          isNot(MovieCollectionReference().limit(2)),
        );

        expect(
          MovieCollectionReference(customFirestore).limit(1),
          isNot(MovieCollectionReference().limit(1)),
        );
        expect(
          MovieCollectionReference(customFirestore).limit(1),
          MovieCollectionReference(customFirestore).limit(1),
        );
      });
    });

    group('sub query', () {
      test('overrides ==', () {
        expect(
          MovieCollectionReference().doc('123').comments.limit(1),
          MovieCollectionReference(FirebaseFirestore.instance)
              .doc('123')
              .comments
              .limit(1),
        );
        expect(
          MovieCollectionReference().doc('123').comments.limit(1),
          isNot(MovieCollectionReference().doc('456').comments.limit(1)),
        );
        expect(
          MovieCollectionReference().doc('123').comments.limit(1),
          isNot(MovieCollectionReference().doc('123').comments.limit(2)),
        );

        expect(
          MovieCollectionReference(customFirestore)
              .doc('123')
              .comments
              .limit(1),
          isNot(MovieCollectionReference().doc('123').comments.limit(1)),
        );
        expect(
          MovieCollectionReference(customFirestore)
              .doc('123')
              .comments
              .limit(1),
          MovieCollectionReference(customFirestore)
              .doc('123')
              .comments
              .limit(1),
        );
      });
    });

    test('supports DateTimes', () async {
      final ref = await initializeTest(dateTimeQueryRef);

      await ref.add(DateTimeQuery(DateTime(1990)));
      await ref.add(DateTimeQuery(DateTime(2000)));
      await ref.add(DateTimeQuery(DateTime(2010)));

      final snapshot = await ref.orderByTime(startAt: DateTime(2000)).get();

      expect(snapshot.docs.length, 2);

      expect(snapshot.docs[0].data.time, DateTime(2000));
      expect(snapshot.docs[1].data.time, DateTime(2010));
    });

    test('supports Timestamp', () async {
      final ref = await initializeTest(timestampQueryRef);

      await ref.add(TimestampQuery(Timestamp.fromDate(DateTime(1990))));
      await ref.add(TimestampQuery(Timestamp.fromDate(DateTime(2000))));
      await ref.add(TimestampQuery(Timestamp.fromDate(DateTime(2010))));

      final snapshot = await ref
          .orderByTime(startAt: Timestamp.fromDate(DateTime(2000)))
          .get();

      expect(snapshot.docs.length, 2);

      expect(snapshot.docs[0].data.time, Timestamp.fromDate(DateTime(2000)));
      expect(snapshot.docs[1].data.time, Timestamp.fromDate(DateTime(2010)));
    });

    test('supports GeoPoint', () async {
      final ref = await initializeTest(geoPointQueryRef);

      await ref.add(GeoPointQuery(const GeoPoint(19, 0)));
      await ref.add(GeoPointQuery(const GeoPoint(20, 0)));
      await ref.add(GeoPointQuery(const GeoPoint(20, 0)));

      final snapshot =
          await ref.orderByPoint(startAt: const GeoPoint(20, 0)).get();

      expect(snapshot.docs.length, 2);

      expect(snapshot.docs[0].data.point, const GeoPoint(20, 0));
      expect(snapshot.docs[1].data.point, const GeoPoint(20, 0));
    });

    test(
      'supports DocumentReference',
      () async {
        final ref = await initializeTest(documentReferenceRef);

        await ref.add(
          DocumentReferenceQuery(FirebaseFirestore.instance.doc('foo/a')),
        );
        await ref.add(
          DocumentReferenceQuery(FirebaseFirestore.instance.doc('foo/b')),
        );
        await ref.add(
          DocumentReferenceQuery(FirebaseFirestore.instance.doc('foo/c')),
        );

        final snapshot = await ref
            .orderByRef(startAt: FirebaseFirestore.instance.doc('foo/b'))
            .get();

        expect(snapshot.docs.length, 2);

        expect(
          snapshot.docs[0].data.ref,
          FirebaseFirestore.instance.doc('foo/b'),
        );
        expect(
          snapshot.docs[1].data.ref,
          FirebaseFirestore.instance.doc('foo/c'),
        );
      },
      skip: 'Blocked by FlutterFire support for querying document references',
    );
  });

  group('FirebaeFirestore.myCustomNamedQuery()', () {
    Future<Uint8List> loadBundleSetup() async {
      // endpoint serves a bundle with 3 documents each containing
      // a 'number' property that increments in value 1-3.
      final url = Uri.https('api.rnfirebase.io', '/firestore/bundle-4');
      final response = await http.get(url);
      final string = response.body;
      return Uint8List.fromList(string.codeUnits);
    }

    test('myCustomNamedQuery() successful', () async {
      final buffer = await loadBundleSetup();
      final task = FirebaseFirestore.instance.loadBundle(buffer);

      // ensure the bundle has been completely cached
      await task.stream.last;

      // namedQuery 'named-bundle-test' which returns a QuerySnaphot of the same 3 documents
      // with 'number' property
      final snapshot = await FirebaseFirestore.instance.namedBundleTest4Get(
        options: const GetOptions(source: Source.cache),
      );

      expect(
        snapshot.docs.map((document) => document.data.number),
        everyElement(anyOf(1, 2, 3)),
      );
    });
  });
}
