// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_list.dart';
import 'package:firebase_database/ui/firebase_sorted_list.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FirebaseList', () {
    late StreamController<DatabaseEvent> onChildAddedStreamController;
    late StreamController<DatabaseEvent> onChildRemovedStreamController;
    late StreamController<DatabaseEvent> onChildChangedStreamController;
    late StreamController<DatabaseEvent> onChildMovedStreamController;
    late StreamController<DatabaseEvent> onValue;
    late MockQuery query;
    late FirebaseList list;
    late Completer<ListChange> callbackCompleter;

    setUp(() {
      onChildAddedStreamController = StreamController<DatabaseEvent>();
      onChildRemovedStreamController = StreamController<DatabaseEvent>();
      onChildChangedStreamController = StreamController<DatabaseEvent>();
      onChildMovedStreamController = StreamController<DatabaseEvent>();
      onValue = StreamController<DatabaseEvent>();
      query = MockQuery(
        onChildAddedStreamController.stream,
        onChildRemovedStreamController.stream,
        onChildChangedStreamController.stream,
        onChildMovedStreamController.stream,
        onValue.stream,
      );
      callbackCompleter = Completer<ListChange>();

      void completeWithChange(int index, DataSnapshot snapshot) {
        callbackCompleter.complete(ListChange.at(index, snapshot));
      }

      void completeWithMove(int from, int to, DataSnapshot snapshot) {
        callbackCompleter.complete(ListChange.move(from, to, snapshot));
      }

      list = FirebaseList(
        query: query,
        onChildAdded: completeWithChange,
        onChildRemoved: completeWithChange,
        onChildChanged: completeWithChange,
        onChildMoved: completeWithMove,
      );
    });

    tearDown(() {
      onChildAddedStreamController.close();
      onChildRemovedStreamController.close();
      onChildChangedStreamController.close();
      onChildMovedStreamController.close();
      onValue.close();
    });

    Future<ListChange> resetCompleterOnCallback() async {
      final ListChange result = await callbackCompleter.future;
      callbackCompleter = Completer<ListChange>();
      return result;
    }

    Future<ListChange> processChildAddedEvent(DatabaseEvent event) {
      onChildAddedStreamController.add(event);
      return resetCompleterOnCallback();
    }

    Future<ListChange> processChildRemovedEvent(DatabaseEvent event) {
      onChildRemovedStreamController.add(event);
      return resetCompleterOnCallback();
    }

    Future<ListChange> processChildChangedEvent(DatabaseEvent event) {
      onChildChangedStreamController.add(event);
      return resetCompleterOnCallback();
    }

    Future<ListChange> processChildMovedEvent(DatabaseEvent event) {
      onChildMovedStreamController.add(event);
      return resetCompleterOnCallback();
    }

    test('can add to empty list', () async {
      final DataSnapshot snapshot = MockDataSnapshot('key10', 10);
      expect(
        await processChildAddedEvent(
          MockEvent(
            DatabaseEventType.childAdded,
            null,
            snapshot,
          ),
        ),
        ListChange.at(0, snapshot),
      );
      expect(list, <DataSnapshot>[snapshot]);
    });

    test('can add before first element', () async {
      final DataSnapshot snapshot1 = MockDataSnapshot('key10', 10);
      final DataSnapshot snapshot2 = MockDataSnapshot('key20', 20);
      await processChildAddedEvent(
        MockEvent(
          DatabaseEventType.childAdded,
          null,
          snapshot2,
        ),
      );
      expect(
        await processChildAddedEvent(
          MockEvent(
            DatabaseEventType.childAdded,
            null,
            snapshot1,
          ),
        ),
        ListChange.at(0, snapshot1),
      );
      expect(list, <DataSnapshot>[snapshot1, snapshot2]);
    });

    test('can add after last element', () async {
      final DataSnapshot snapshot1 = MockDataSnapshot('key10', 10);
      final DataSnapshot snapshot2 = MockDataSnapshot('key20', 20);
      await processChildAddedEvent(
        MockEvent(
          DatabaseEventType.childAdded,
          null,
          snapshot1,
        ),
      );
      expect(
        await processChildAddedEvent(
          MockEvent(
            DatabaseEventType.childAdded,
            'key10',
            snapshot2,
          ),
        ),
        ListChange.at(1, snapshot2),
      );
      expect(list, <DataSnapshot>[snapshot1, snapshot2]);
    });

    test('can remove from singleton list', () async {
      final DataSnapshot snapshot = MockDataSnapshot('key10', 10);
      await processChildAddedEvent(
        MockEvent(
          DatabaseEventType.childAdded,
          null,
          snapshot,
        ),
      );
      expect(
        await processChildRemovedEvent(
          MockEvent(
            DatabaseEventType.childRemoved,
            null,
            snapshot,
          ),
        ),
        ListChange.at(0, snapshot),
      );
      expect(list, isEmpty);
    });

    test('can remove former of two elements', () async {
      final DataSnapshot snapshot1 = MockDataSnapshot('key10', 10);
      final DataSnapshot snapshot2 = MockDataSnapshot('key20', 20);
      await processChildAddedEvent(
        MockEvent(
          DatabaseEventType.childAdded,
          null,
          snapshot2,
        ),
      );
      await processChildAddedEvent(
        MockEvent(
          DatabaseEventType.childAdded,
          null,
          snapshot1,
        ),
      );
      expect(
        await processChildRemovedEvent(
          MockEvent(
            DatabaseEventType.childRemoved,
            null,
            snapshot1,
          ),
        ),
        ListChange.at(0, snapshot1),
      );
      expect(list, <DataSnapshot>[snapshot2]);
    });

    test('can remove latter of two elements', () async {
      final DataSnapshot snapshot1 = MockDataSnapshot('key10', 10);
      final DataSnapshot snapshot2 = MockDataSnapshot('key20', 20);
      await processChildAddedEvent(
        MockEvent(
          DatabaseEventType.childAdded,
          null,
          snapshot2,
        ),
      );
      await processChildAddedEvent(
        MockEvent(
          DatabaseEventType.childAdded,
          null,
          snapshot1,
        ),
      );
      expect(
        await processChildRemovedEvent(
          MockEvent(
            DatabaseEventType.childRemoved,
            'key10',
            snapshot2,
          ),
        ),
        ListChange.at(1, snapshot2),
      );
      expect(list, <DataSnapshot>[snapshot1]);
    });

    test('can change child', () async {
      final DataSnapshot snapshot1 = MockDataSnapshot('key10', 10);
      final DataSnapshot snapshot2a = MockDataSnapshot('key20', 20);
      final DataSnapshot snapshot2b = MockDataSnapshot('key20', 25);
      final DataSnapshot snapshot3 = MockDataSnapshot('key30', 30);
      await processChildAddedEvent(
        MockEvent(
          DatabaseEventType.childAdded,
          null,
          snapshot3,
        ),
      );
      await processChildAddedEvent(
        MockEvent(
          DatabaseEventType.childAdded,
          null,
          snapshot2a,
        ),
      );
      await processChildAddedEvent(
        MockEvent(
          DatabaseEventType.childAdded,
          null,
          snapshot1,
        ),
      );
      expect(
        await processChildChangedEvent(
          MockEvent(DatabaseEventType.childChanged, 'key10', snapshot2b),
        ),
        ListChange.at(1, snapshot2b),
      );
      expect(list, <DataSnapshot>[snapshot1, snapshot2b, snapshot3]);
    });
    test('can move child', () async {
      final DataSnapshot snapshot1 = MockDataSnapshot('key10', 10);
      final DataSnapshot snapshot2 = MockDataSnapshot('key20', 20);
      final DataSnapshot snapshot3 = MockDataSnapshot('key30', 30);
      await processChildAddedEvent(
        MockEvent(
          DatabaseEventType.childAdded,
          null,
          snapshot3,
        ),
      );
      await processChildAddedEvent(
        MockEvent(
          DatabaseEventType.childAdded,
          null,
          snapshot2,
        ),
      );
      await processChildAddedEvent(
        MockEvent(
          DatabaseEventType.childAdded,
          null,
          snapshot1,
        ),
      );
      expect(
        await processChildMovedEvent(
          MockEvent(
            DatabaseEventType.childMoved,
            'key30',
            snapshot1,
          ),
        ),
        ListChange.move(0, 2, snapshot1),
      );
      expect(list, <DataSnapshot>[snapshot2, snapshot3, snapshot1]);
    });
  });

  test('FirebaseList listeners are optional', () {
    final onChildAddedStreamController = StreamController<DatabaseEvent>();
    final onChildRemovedStreamController = StreamController<DatabaseEvent>();
    final onChildChangedStreamController = StreamController<DatabaseEvent>();
    final onChildMovedStreamController = StreamController<DatabaseEvent>();
    final onValue = StreamController<DatabaseEvent>();
    addTearDown(() {
      onChildChangedStreamController.close();
      onChildRemovedStreamController.close();
      onChildAddedStreamController.close();
      onChildMovedStreamController.close();
      onValue.close();
    });

    final query = MockQuery(
      onChildAddedStreamController.stream,
      onChildRemovedStreamController.stream,
      onChildChangedStreamController.stream,
      onChildMovedStreamController.stream,
      onValue.stream,
    );
    final list = FirebaseList(query: query);
    addTearDown(list.clear);

    expect(onChildAddedStreamController.hasListener, isFalse);
    expect(onChildRemovedStreamController.hasListener, isFalse);
    expect(onChildChangedStreamController.hasListener, isFalse);
    expect(onChildMovedStreamController.hasListener, isFalse);
    expect(onValue.hasListener, isFalse);
  });

  test('FirebaseSortedList listeners are optional', () {
    final onChildAddedStreamController = StreamController<DatabaseEvent>();
    final onChildRemovedStreamController = StreamController<DatabaseEvent>();
    final onChildChangedStreamController = StreamController<DatabaseEvent>();
    final onChildMovedStreamController = StreamController<DatabaseEvent>();
    final onValue = StreamController<DatabaseEvent>();
    addTearDown(() {
      onChildChangedStreamController.close();
      onChildRemovedStreamController.close();
      onChildAddedStreamController.close();
      onChildMovedStreamController.close();
      onValue.close();
    });

    final query = MockQuery(
      onChildAddedStreamController.stream,
      onChildRemovedStreamController.stream,
      onChildChangedStreamController.stream,
      onChildMovedStreamController.stream,
      onValue.stream,
    );
    final list = FirebaseSortedList(query: query, comparator: (a, b) => 0);
    addTearDown(list.clear);

    expect(onChildAddedStreamController.hasListener, isFalse);
    expect(onChildRemovedStreamController.hasListener, isFalse);
    expect(onChildChangedStreamController.hasListener, isFalse);
    expect(onChildMovedStreamController.hasListener, isFalse);
    expect(onValue.hasListener, isFalse);
  });
}

class MockQuery extends Mock implements Query {
  MockQuery(
    this.onChildAdded,
    this.onChildRemoved,
    this.onChildChanged,
    this.onChildMoved,
    this.onValue,
  );

  @override
  final Stream<DatabaseEvent> onChildAdded;

  @override
  final Stream<DatabaseEvent> onChildRemoved;

  @override
  final Stream<DatabaseEvent> onChildChanged;

  @override
  final Stream<DatabaseEvent> onChildMoved;

  @override
  final Stream<DatabaseEvent> onValue;
}

class ListChange {
  ListChange.at(int index, DataSnapshot snapshot)
      : this._(index, null, snapshot);

  ListChange.move(int from, int to, DataSnapshot snapshot)
      : this._(from, to, snapshot);

  ListChange._(this.index, this.index2, this.snapshot);

  final int index;
  final int? index2;
  final DataSnapshot snapshot;

  @override
  // ignore: no_runtimetype_tostring
  String toString() => '$runtimeType[$index, $index2, $snapshot]';

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object o) {
    return o is ListChange &&
        index == o.index &&
        index2 == o.index2 &&
        snapshot == o.snapshot;
  }

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => index;
}

class MockEvent implements DatabaseEvent {
  MockEvent(this.type, this.previousChildKey, this.snapshot);

  @override
  final DatabaseEventType type;

  @override
  final String? previousChildKey;

  @override
  final DataSnapshot snapshot;

  @override
  // ignore: no_runtimetype_tostring
  String toString() => '$runtimeType[$previousChildKey, $snapshot]';

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object o) {
    return o is MockEvent &&
        previousChildKey == o.previousChildKey &&
        snapshot == o.snapshot;
  }

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => previousChildKey.hashCode;
}

class MockDataSnapshot implements DataSnapshot {
  MockDataSnapshot(this.key, this.value) : exists = value != null;

  @override
  final String key;

  @override
  final dynamic value;

  @override
  final bool exists;

  @override
  // ignore: no_runtimetype_tostring
  String toString() => '$runtimeType[$key, $value]';

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object o) {
    return o is MockDataSnapshot && key == o.key && value == o.value;
  }

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => key.hashCode;

  @override
  bool hasChild(String path) {
    throw UnimplementedError();
  }

  @override
  DataSnapshot child(String path) {
    throw UnimplementedError();
  }

  @override
  Object? get priority => throw UnimplementedError();

  @override
  DatabaseReference get ref => throw UnimplementedError();

  @override
  Iterable<DataSnapshot> get children => throw UnimplementedError();
}
