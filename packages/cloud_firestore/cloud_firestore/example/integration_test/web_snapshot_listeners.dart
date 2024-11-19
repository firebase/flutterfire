// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

// Run only on web for demonstrating snapshot listener clean up in debug mode does not clean up the listeners incorrectly.
// See: https://github.com/firebase/flutterfire/issues/13019
void runWebSnapshotListenersTests() {
  group('Web snapshot listeners', () {
    late FirebaseFirestore firestore;
    late CollectionReference<Map<String, dynamic>> collection;
    late DocumentReference<Map<String, dynamic>> document;
    late DocumentReference<Map<String, dynamic>> document2;
    setUpAll(() async {
      firestore = FirebaseFirestore.instance;
      collection = firestore
          .collection('flutter-tests/web-snapshot-listeners/query-tests');
      document = collection.doc('doc1');
      document2 = collection.doc('doc1');

      await Future.wait([
        document.set({'foo': 1}),
        collection.add({'foo': 2}),
        collection.add({'foo': 3}),
      ]);
    });

    test(
      'document snapshot listeners in debug',
      () async {
        Completer<bool> completer = Completer<bool>();
        Completer<bool> completer2 = Completer<bool>();
        Completer<bool> completer3 = Completer<bool>();
        document.snapshots().listen((snapshot) {
          if (completer.isCompleted) {
            return;
          }
          completer.complete(true);
        });

        document.snapshots().listen((snapshot) {
          if (completer2.isCompleted) {
            return;
          }
          completer2.complete(true);
        });

        document.snapshots().listen((snapshot) {
          if (completer3.isCompleted) {
            return;
          }
          completer3.complete(true);
        });

        final one = await completer.future;
        final two = await completer2.future;
        final three = await completer3.future;

        expect(one, true);
        expect(two, true);
        expect(three, true);
      },
      skip: !kIsWeb,
    );

    test(
      'document snapshot listeners with different doc refs in debug',
      () async {
        Completer<bool> completer = Completer<bool>();
        Completer<bool> completer2 = Completer<bool>();
        Completer<bool> completer3 = Completer<bool>();
        Completer<bool> completer4 = Completer<bool>();
        document.snapshots().listen((snapshot) {
          if (completer.isCompleted) {
            return;
          }
          completer.complete(true);
        });

        document.snapshots().listen((snapshot) {
          if (completer2.isCompleted) {
            return;
          }
          completer2.complete(true);
        });

        document2.snapshots().listen((snapshot) {
          if (completer3.isCompleted) {
            return;
          }
          completer3.complete(true);
        });

        document2.snapshots().listen((snapshot) {
          if (completer4.isCompleted) {
            return;
          }
          completer4.complete(true);
        });

        final one = await completer.future;
        final two = await completer2.future;
        final three = await completer3.future;
        final four = await completer4.future;

        expect(one, true);
        expect(two, true);
        expect(three, true);
        expect(four, true);
      },
      skip: !kIsWeb,
    );

    test(
      'query snapshot listeners in debug',
      () async {
        Completer<bool> completer = Completer<bool>();
        Completer<bool> completer2 = Completer<bool>();
        Completer<bool> completer3 = Completer<bool>();
        collection.snapshots().listen((snapshot) {
          if (completer.isCompleted) {
            return;
          }
          completer.complete(true);
        });

        collection.snapshots().listen((snapshot) {
          if (completer2.isCompleted) {
            return;
          }
          completer2.complete(true);
        });

        collection.snapshots().listen((snapshot) {
          if (completer3.isCompleted) {
            return;
          }
          completer3.complete(true);
        });
        final one = await completer.future;
        final two = await completer2.future;
        final three = await completer3.future;

        expect(one, true);
        expect(two, true);
        expect(three, true);
      },
      skip: !kIsWeb,
    );

    test(
      'snapshot in sync listeners in debug',
      () async {
        Completer<bool> completer = Completer<bool>();
        Completer<bool> completer2 = Completer<bool>();
        Completer<bool> completer3 = Completer<bool>();
        firestore.snapshotsInSync().listen((snapshot) {
          if (completer.isCompleted) {
            return;
          }
          completer.complete(true);
        });

        firestore.snapshotsInSync().listen((snapshot) {
          if (completer2.isCompleted) {
            return;
          }
          completer2.complete(true);
        });

        firestore.snapshotsInSync().listen((snapshot) {
          if (completer3.isCompleted) {
            return;
          }
          completer3.complete(true);
        });

        final one = await completer.future;
        final two = await completer2.future;
        final three = await completer3.future;

        expect(one, true);
        expect(two, true);
        expect(three, true);
      },
      skip: !kIsWeb,
    );
  });
}
