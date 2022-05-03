import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterfire_ui/src/firestore/table_builder.dart';

Future<void> main() async {
  final instance = FakeFirebaseFirestore();
  final collection = instance.collection('persons').withConverter<Person>(
        fromFirestore: (snapshot, options) => Person.fromMap(snapshot.data()!),
        toFirestore: (data, option) => data.toMap(),
      );

  final bob = Person(
    firstName: 'Bob',
    address: Address(street: 'Awesome Road', city: 'FlutterFire City'),
  );
  await collection.add(bob);

  testWidgets('TableBuilder WITOUT CelBuilder is render as expected',
      (WidgetTester tester) async {
    // Create the widget by telling the tester to build it.

    await tester.pumpWidget(_basic(collection, null));

    await tester.pumpAndSettle();

    // final cityFinder = find.text('FlutterFire City');

    final streetFinder =
        find.text('{street: ${bob.address.street}, city: ${bob.address.city}}');
    final firstNameFinder = find.text(bob.firstName);

    // expect(cityFinder, findsOneWidget);
    expect(streetFinder, findsOneWidget);
    expect(firstNameFinder, findsOneWidget);
  });

  testWidgets('TableBuilder CelBuilder is render as expected',
      (WidgetTester tester) async {
    // Create the widget by telling the tester to build it.

    await tester.pumpWidget(
      _basic(collection, (data, colIndex) {
        final person = Person.fromMap(data);
        if (colIndex == 0) {
          return Text(person.firstName);
        }

        if (colIndex == 1) {
          return Row(
            children: [
              Text(person.address.street),
              Text(person.address.city),
            ],
          );
        }
        return Container();
      }),
    );

    await tester.pumpAndSettle();

    final cityFinder = find.text(bob.address.city);
    final streetFinder = find.text(bob.address.street);
    final firstNameFinder = find.text(bob.firstName);

    expect(cityFinder, findsOneWidget);
    expect(streetFinder, findsOneWidget);
    expect(firstNameFinder, findsOneWidget);
  });
}

Widget _basic(
  CollectionReference<Person> col,
  CellBuilder? builder,
) {
  return MaterialApp(
    home: FirestoreDataTable(
      query: col,
      columnLabels: const {
        'firstName': Text('First Name'),
        'address': Text('Address'),
      },
      cellBuilder: builder,
    ),
  );
}

@immutable
class Person {
  Person({
    required this.firstName,
    required this.address,
  });

  final String firstName;
  final Address address;

  Person copyWith({
    String? firstName,
    Address? address,
  }) {
    return Person(
      firstName: firstName ?? this.firstName,
      address: address ?? this.address,
    );
  }

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

  @override
  String toString() => 'Person(firstName: $firstName, address: $address)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Person &&
        other.firstName == firstName &&
        other.address == address;
  }

  @override
  int get hashCode => firstName.hashCode ^ address.hashCode;
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

  @override
  String toString() => 'Address(street: $street, city: $city)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Address && other.street == street && other.city == city;
  }

  @override
  int get hashCode => street.hashCode ^ city.hashCode;
}
