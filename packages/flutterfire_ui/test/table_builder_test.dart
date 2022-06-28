import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutterfire_ui/src/firestore/table_builder.dart';

Future<void> main() async {
  final instance = FakeFirebaseFirestore();
  final collection = instance.collection('persons');
  final bob = Person(
    firstName: 'Bob',
    address: Address(street: 'Awesome Road', city: 'FlutterFire City'),
  );
  final bob2 = Person(
    firstName: 'Bob #2',
    address: Address(street: 'Awesome Road', city: 'FlutterFire City'),
  );

  setUp(() async {
    await collection.add(bob.toMap());
    await collection.add(bob2.toMap());
  });

  tearDown(() async {
    final docsSnapshot = await collection.get();
    for (final id in docsSnapshot.docs.map((e) => e.id)) {
      await (collection.doc(id)).delete();
    }
  });

  testWidgets(
    'FirestoreDataTable without CellBuilder is render as expected',
    (WidgetTester tester) async {
      await tester.pumpWidget(_dataTableBuilder(query: collection));

      await tester.pumpAndSettle();

      final streetFinder = find
          .text('{street: ${bob.address.street}, city: ${bob.address.city}}');
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

            await doc.reference.set(
              person
                  .copyWith(firstName: person.firstName.toUpperCase())
                  .toMap(),
            );
          },
        ),
      );

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
  Person({
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
  Address({
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
