import 'package:cloud_firestore_odm/cloud_firestore_odm.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Id', () {
    // ignore: prefer_const_constructors, coverage for the const constructor
    Id();
  });

  test('JsonMapWithId', () {
    expect(
      $JsonMapWithId({'a': 42}, '123', 'id'),
      {'a': 42, 'id': '123'},
    );

    expect(
      $JsonMapWithId({'b': 21}, '456', 'foo'),
      {'b': 21, 'foo': '456'},
    );

    final map = {'a': 21};
    final mapWithId = $JsonMapWithId(map, '123', 'id');

    mapWithId['a'] = 42;

    expect(map, {'a': 42});

    expect(
      () => mapWithId['id'] = '456',
      throwsUnsupportedError,
    );

    expect(
      mapWithId.containsValue('123'),
      true,
    );
    expect(
      mapWithId.containsValue(42),
      true,
    );
    expect(
      mapWithId.containsValue(21),
      false,
    );
  });
}
