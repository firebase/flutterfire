// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// @dart=2.9

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void runInstanceTests() {
  group('$FirebaseFirestore.instance', () {
    FirebaseFirestore /*?*/ firestore;

    setUpAll(() async {
      firestore = FirebaseFirestore.instance;
    });

    test('snapshotsInSync()', () async {
      DocumentReference documentReference =
          firestore.doc('flutter-tests/insync');

      // Ensure deleted
      await documentReference.delete();

      StreamController controller = StreamController();
      StreamSubscription insync;
      StreamSubscription snapshots;

      int inSyncCount = 0;

      insync = firestore.snapshotsInSync().listen((_) {
        controller.add('insync=$inSyncCount');
        inSyncCount++;
      });

      snapshots = documentReference.snapshots().listen((ds) {
        controller.add('snapshot-exists=${ds.exists}');
      });

      // Allow the snapshots to trigger...
      await Future.delayed(const Duration(seconds: 1));

      await documentReference.set({'foo': 'bar'});

      await expectLater(
          controller.stream,
          emitsInOrder([
            'insync=0', // No other snapshots
            'snapshot-exists=false',
            'insync=1',
            'snapshot-exists=true',
            'insync=2',
          ]));

      await controller.close();
      await insync.cancel();
      await snapshots.cancel();
    });

    test('enableNetwork()', () async {
      if (kIsWeb) return;

      // Write some data while online
      await firestore.enableNetwork();
      DocumentReference documentReference =
          firestore.doc('flutter-tests/enable-network');
      await documentReference.set({'foo': 'bar'});

      // Disable the network
      await firestore.disableNetwork();

      StreamController controller = StreamController();

      // Set some data while offline
      // ignore: unawaited_futures
      documentReference.set({'foo': 'baz'}).then((_) async {
        // Only when back online will this trigger
        controller.add(true);
      });

      // Go back online
      await firestore.enableNetwork();

      await expectLater(controller.stream, emits(true));
      await controller.close();
    });

    test('disableNetwork()', () async {
      if (kIsWeb) return;

      // Write some data while online
      await firestore.enableNetwork();
      DocumentReference documentReference =
          firestore.doc('flutter-tests/disable-network');
      await documentReference.set({'foo': 'bar'});

      // Disable the network
      await firestore.disableNetwork();

      // Get data from cache
      DocumentSnapshot documentSnapshot = await documentReference.get();
      expect(documentSnapshot.metadata.isFromCache, isTrue);
      expect(documentSnapshot.data()['foo'], equals('bar'));

      // Go back online once test complete
      await firestore.enableNetwork();
    });

    test('waitForPendingWrites()', () async {
      await firestore.waitForPendingWrites();
    }, skip: kIsWeb);

    test('terminate() / clearPersistence()', () async {
      // Since the firestore instance has already been used,
      // calling `clearPersistence` will throw a native error.
      // We first check it does throw as expected, then terminate
      // the instance, and then check whether clearing succeeds.
      try {
        await firestore.clearPersistence();
        fail('Should have thrown');
      } on FirebaseException catch (e) {
        expect(e.code, equals('failed-precondition'));
      } catch (e) {
        fail(e);
      }

      await firestore.terminate();
      await firestore.clearPersistence();
    });
  }, skip: kIsWeb);
}
