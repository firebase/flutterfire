import 'package:cloud_firestore_odm_example/integration/freezed.dart';
import 'package:flutter_test/flutter_test.dart';

import 'common.dart';

void main() {
  test('supports field renaming', () async {
    final collection = await initializeTest(PersonCollectionReference());

    await collection.add(Person(firstName: 'A', lastName: 'A'));
    await collection.add(Person(firstName: 'John', lastName: 'Doe'));
    await collection.add(Person(firstName: 'John', lastName: 'Smith'));
    await collection.add(Person(firstName: 'Mike', lastName: 'Doe'));

    expect(
      await collection.reference
          .orderBy('first_name')
          .orderBy('LAST_NAME')
          .get()
          .then((value) => value.docs.map((e) => e.data().toJson())),
      [
        {'first_name': 'A', 'LAST_NAME': 'A'},
        {'first_name': 'John', 'LAST_NAME': 'Doe'},
        {'first_name': 'John', 'LAST_NAME': 'Smith'},
        {'first_name': 'Mike', 'LAST_NAME': 'Doe'},
      ],
    );

    expect(
      await collection
          .orderByFirstName(startAt: 'B')
          .get()
          .then((value) => value.docs.map((e) => e.data.firstName)),
      ['John', 'John', 'Mike'],
    );
    expect(
      await collection
          .orderByLastName(startAt: 'B')
          .get()
          .then((value) => value.docs.map((e) => e.data.lastName)),
      ['Doe', 'Doe', 'Smith'],
    );
    expect(
      await collection
          .whereLastName(isEqualTo: 'Doe')
          .get()
          .then((value) => value.docs.map((e) => e.data.firstName)),
      unorderedEquals(<Object?>['John', 'Mike']),
    );
  });
}
