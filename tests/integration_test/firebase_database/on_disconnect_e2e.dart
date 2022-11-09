// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';

void setupOnDisconnectTests() {
  group('OnDisconnect', () {
    late FirebaseDatabase database;
    late DatabaseReference ref;

    setUp(() async {
      database = FirebaseDatabase.instance;
      ref = database.ref('tests');

      // Wipe the database before each test
      await ref.remove();
    });

    Future<void> toggleState() async {
      await database.goOffline();
      await database.goOnline();
    }

    tearDown(() async {
      await FirebaseDatabase.instance.goOnline();
    });

    test('sets a value on disconnect', () async {
      await ref.onDisconnect().set('foo');
      await toggleState();
      var snapshot = await ref.get();
      expect(snapshot.value, 'foo');
    });

    test('sets a value with priority on disconnect', () async {
      await ref.onDisconnect().setWithPriority('foo', 3);
      await toggleState();
      var snapshot = await ref.get();
      expect(snapshot.value, 'foo');
      expect(snapshot.priority, 3);
    });

    test('removes a node on disconnect', () async {
      await ref.set('foo');
      await ref.onDisconnect().remove();
      await toggleState();
      var snapshot = await ref.get();
      expect(snapshot.exists, isFalse);
    });

    test('updates a node on disconnect', () async {
      await ref.set({'foo': 'bar'});
      await ref.onDisconnect().update({'bar': 'baz'});
      await toggleState();
      var snapshot = await ref.get();
      expect(
        snapshot.value,
        equals({
          'foo': 'bar',
          'bar': 'baz',
        }),
      );
    });

    test('cancels disconnect operations', () async {
      await ref.set('foo');
      await ref.onDisconnect().remove();
      await ref.onDisconnect().cancel();
      await toggleState();
      var snapshot = await ref.get();
      expect(
        snapshot.value,
        'foo',
      );
    });
  });
}
