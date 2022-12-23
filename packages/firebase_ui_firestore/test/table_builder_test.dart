// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: subtype_of_sealed_class, must_be_immutable, avoid_implementing_value_types

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mockito/mockito.dart';

typedef Snapshot = QuerySnapshot<Map<String, Object?>>;

const bob = Person(
  firstName: 'Bob',
  address: Address(street: 'Awesome Road', city: 'FlutterFire City'),
);
const bob2 = Person(
  firstName: 'Bob #2',
  address: Address(street: 'Awesome Road', city: 'FlutterFire City'),
);

Future<void> main() async {
  setUp(() async {
    when(bobSnapshot.data()).thenReturn(bob.toMap());
    when(bob2Snapshot.data()).thenReturn(bob2.toMap());
  });

  testWidgets(
    'FirestoreDataTable without CellBuilder is render as expected',
    (WidgetTester tester) async {
      await tester.pumpWidget(_dataTableBuilder(query: collection));
      mockCtrl.add(mockQuerySnapshot);

      await tester.pumpAndSettle();

      final street = bob.address.street;
      final city = bob.address.city;

      final streetFinder = find.text('{street: $street, city: $city}');
      final firstNameFinder = find.text(bob.firstName);

      expect(streetFinder, findsNWidgets(2));
      expect(firstNameFinder, findsOneWidget);
    },
  );

  testWidgets(
    'FirestoreDataTable with CellBuilder is render as expected',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _dataTableBuilder(
          query: collection,
          cellBuilder: _defaultCellBuilder,
        ),
      );

      mockCtrl.add(mockQuerySnapshot);

      await tester.pumpAndSettle();

      final cityFinder = find.text(bob.address.city);
      final streetFinder = find.text(bob.address.street);
      final firstNameFinder = find.text(bob.firstName);

      expect(cityFinder, findsNWidgets(2));
      expect(streetFinder, findsNWidgets(2));
      expect(firstNameFinder, findsOneWidget);
    },
  );

  testWidgets(
    'FirestoreDataTable with default dell dialog editor is render as expected',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _dataTableBuilder(
          query: collection,
          cellBuilder: _defaultCellBuilder,
        ),
      );

      mockCtrl.add(mockQuerySnapshot);

      await tester.pumpAndSettle();

      final firstNameFinder = find.text(bob.firstName);
      expect(firstNameFinder, findsOneWidget);

      await tester.tap(firstNameFinder);
      await tester.pumpAndSettle();

      final dialogFinder = find.byType(Dialog);

      expect(dialogFinder, findsOneWidget);
    },
  );

  testWidgets(
    'FirestoreDataTable without default dell dialog editor is render as expected',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _dataTableBuilder(
          query: collection,
          cellBuilder: _defaultCellBuilder,
          enableDefaultCellEditor: false,
        ),
      );

      mockCtrl.add(mockQuerySnapshot);

      await tester.pumpAndSettle();

      final firstNameFinder = find.text(bob.firstName);
      expect(firstNameFinder, findsOneWidget);

      //For some reason, we have a renderflex issue when tapping
      tester.binding.window.physicalSizeTestValue = const Size(1000, 2000);
      await tester.tap(firstNameFinder);
      await tester.pumpAndSettle();

      final dialogFinder = find.byType(Dialog);

      expect(dialogFinder, findsNothing);
    },
  );

  testWidgets(
    'FirestoreDataTable overide the default cell dialog editor is render as expected',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _dataTableBuilder(
          query: collection,
          cellBuilder: _defaultCellBuilder,
          onTapCell: (doc, value, colKey) async {
            final person = Person.fromMap(doc.data());
            when(bobSnapshot.data()).thenReturn(
              person
                  .copyWith(firstName: person.firstName.toUpperCase())
                  .toMap(),
            );

            mockCtrl.add(mockQuerySnapshot);
          },
        ),
      );

      mockCtrl.add(mockQuerySnapshot);

      await tester.pumpAndSettle();

      Finder firstNameFinder = find.text(bob.firstName);
      expect(firstNameFinder, findsOneWidget);

      //For some reason, we have a renderflex issue when tapping
      tester.binding.window.physicalSizeTestValue = const Size(1000, 2000);
      await tester.tap(firstNameFinder);
      await tester.pumpAndSettle();

      final upperCaseFinder = find.text(bob.firstName.toUpperCase());
      firstNameFinder = find.text(bob.firstName);

      expect(upperCaseFinder, findsOneWidget);
      expect(firstNameFinder, findsNothing);
    },
  );

  testWidgets(
    'FirestoreDataTable row selection is capture',
    (WidgetTester tester) async {
      //For some reason, we have a renderflex issue when tapping
      tester.binding.window.physicalSizeTestValue = const Size(1000, 2000);

      var nbItemSelected = 0;

      await tester.pumpWidget(
        _dataTableBuilder(
          query: collection,
          cellBuilder: _defaultCellBuilder,
          enableDefaultCellEditor: false,
          onSelectedRows: (selection) {
            nbItemSelected = selection.length;
          },
        ),
      );

      mockCtrl.add(mockQuerySnapshot);

      await tester.pumpAndSettle();

      final firstRowFinder = find.text(bob.firstName);
      expect(firstRowFinder, findsOneWidget);

      await tester.tap(firstRowFinder);
      await tester.pumpAndSettle();

      expect(nbItemSelected, 1);

      final secondRowFinder = find.text(bob2.firstName);
      expect(secondRowFinder, findsOneWidget);
      await tester.tap(secondRowFinder);
      await tester.pumpAndSettle();

      expect(nbItemSelected, 2);

      await tester.tap(firstRowFinder);
      await tester.tap(secondRowFinder);
      await tester.pumpAndSettle();

      expect(nbItemSelected, 0);
    },
  );
}

Widget _defaultCellBuilder(
  QueryDocumentSnapshot<Map<String, Object?>> doc,
  String colKey,
) {
  final person = Person.fromMap(doc.data());

  switch (ColumnKey.values.asNameMap()[colKey]) {
    case ColumnKey.firstName:
      return Text(person.firstName);
    case ColumnKey.address:
      return Row(
        children: [
          Text(person.address.street),
          Text(person.address.city),
        ],
      );
    default:
      return Container();
  }
}

Widget _dataTableBuilder({
  required Query<Object?> query,
  CellBuilder? cellBuilder,
  bool enableDefaultCellEditor = true,
  OnTapCell? onTapCell,
  OnSelectedRows? onSelectedRows,
}) {
  return MaterialApp(
    home: FirestoreDataTable(
      query: query,
      columnLabels: {
        ColumnKey.firstName.name: const Text('First Name'),
        ColumnKey.address.name: const Text('Address'),
      },
      cellBuilder: cellBuilder,
      enableDefaultCellEditor: enableDefaultCellEditor,
      onTapCell: onTapCell,
      onSelectedRows: onSelectedRows,
    ),
  );
}

enum ColumnKey {
  firstName,
  address,
}

@immutable
class Person {
  const Person({
    required this.firstName,
    required this.address,
  });

  final String firstName;
  final Address address;

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'address': address.toMap(),
    };
  }

  factory Person.fromMap(Map<String, dynamic> map) {
    return Person(
      firstName: map['firstName'] ?? '',
      address: Address.fromMap(map['address']),
    );
  }

  Person copyWith({
    String? firstName,
    Address? address,
  }) {
    return Person(
      firstName: firstName ?? this.firstName,
      address: address ?? this.address,
    );
  }
}

@immutable
class Address {
  const Address({
    required this.street,
    required this.city,
  });

  final String street;
  final String city;

  Map<String, dynamic> toMap() {
    return {
      'street': street,
      'city': city,
    };
  }

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      street: map['street'] ?? '',
      city: map['city'] ?? '',
    );
  }
}

class MockFirestore extends Mock implements FirebaseFirestore {}

class MockAggregateQuerySnapshot extends Mock
    implements AggregateQuerySnapshot {
  @override
  int get count => 2;
}

class MockAggregateQuery extends Mock implements AggregateQuery {
  @override
  Future<AggregateQuerySnapshot> get({AggregateSource? source}) {
    return super.noSuchMethod(
      Invocation.method(#get, null),
      returnValue: Future.value(MockAggregateQuerySnapshot()),
      returnValueForMissingStub: Future.value(MockAggregateQuerySnapshot()),
    );
  }
}

class MockCollection extends Mock
    implements CollectionReference<Map<String, Object?>> {
  @override
  Stream<QuerySnapshot<Map<String, Object?>>> snapshots({
    bool includeMetadataChanges = false,
  }) {
    return super.noSuchMethod(
      Invocation.method(#snapshots, null, {
        #includeMetadataChanges: includeMetadataChanges,
      }),
      returnValue: Stream.fromIterable([
        MockQuerySnapshot(),
        MockQuerySnapshot(),
      ]),
      returnValueForMissingStub: Stream.fromIterable([
        MockQuerySnapshot(),
        MockQuerySnapshot(),
      ]),
    );
  }

  @override
  CollectionReference<R> withConverter<R extends Object?>({
    FromFirestore<R>? fromFirestore,
    ToFirestore<R>? toFirestore,
  }) {
    return super.noSuchMethod(
      Invocation.method(#withConverter, null, {
        #fromFirestore: fromFirestore,
        #toFirestore: toFirestore,
      }),
      returnValue: this,
      returnValueForMissingStub: this,
    );
  }

  @override
  MockAggregateQuery count() {
    return super.noSuchMethod(
      Invocation.method(#count, null),
      returnValue: MockAggregateQuery(),
      returnValueForMissingStub: MockAggregateQuery(),
    );
  }

  @override
  Query<Map<String, Object?>> limit([int? limit]) {
    return super.noSuchMethod(
      Invocation.method(
        #limit,
        [limit],
      ),
      returnValue: mockQuery,
      returnValueForMissingStub: mockQuery,
    );
  }
}

final collection = MockCollection();

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, Object?>> {
  final Person person;

  MockDocumentReference(this.person);
}

class MockDocumentSnapshot extends Mock
    implements QueryDocumentSnapshot<Map<String, Object?>> {
  final Person person;

  MockDocumentSnapshot(this.person);

  @override
  DocumentReference<Map<String, Object?>> get reference {
    return super.noSuchMethod(
      Invocation.getter(#reference),
      returnValue: MockDocumentReference(person),
      returnValueForMissingStub: MockDocumentReference(person),
    );
  }

  @override
  String get id {
    return super.noSuchMethod(
      Invocation.getter(#id),
      returnValue: person.hashCode.toString(),
      returnValueForMissingStub: person.hashCode.toString(),
    );
  }

  @override
  Map<String, Object?> data() {
    return super.noSuchMethod(
      Invocation.method(#data, null),
      returnValue: person.toMap(),
      returnValueForMissingStub: person.toMap(),
    );
  }
}

final bobSnapshot = MockDocumentSnapshot(bob);
final bob2Snapshot = MockDocumentSnapshot(bob2);

class MockQuerySnapshot extends Mock implements Snapshot {
  @override
  int get size {
    return super.noSuchMethod(
      Invocation.getter(#size),
      returnValue: 2,
      returnValueForMissingStub: 2,
    );
  }

  @override
  List<QueryDocumentSnapshot<Map<String, Object?>>> get docs {
    return super.noSuchMethod(
      Invocation.getter(#docs),
      returnValue: [
        bobSnapshot,
        bob2Snapshot,
      ],
      returnValueForMissingStub: [
        bobSnapshot,
        bob2Snapshot,
      ],
    );
  }
}

final mockQuerySnapshot = MockQuerySnapshot();
final mockCtrl = StreamController<Snapshot>.broadcast();

class MockQuery extends Mock implements Query<Map<String, Object?>> {
  @override
  Stream<Snapshot> snapshots({
    bool? includeMetadataChanges = false,
  }) {
    return super.noSuchMethod(
      Invocation.method(#snapshots, null, {
        #includeMetadataChanges: includeMetadataChanges,
      }),
      returnValue: mockCtrl.stream,
      returnValueForMissingStub: mockCtrl.stream,
    );
  }
}

final mockQuery = MockQuery();
