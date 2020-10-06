@TestOn('browser')
import 'package:firebase/src/utils.dart';
import 'package:firebase/src/interop/firestore_interop.dart';

import 'package:test/test.dart';

void _testRoundTrip(Object value) {
  var js = jsify(value);
  var roundTrip = dartify(js);
  expect(roundTrip, value);
}

void main() {
  group('jsify and dartify', () {
    group('basic objects', () {
      var jsonObjects = {
        'int': 0,
        'null': null,
        'string': 'string',
        'bool': true,
        'double': 1.1,
        'list': [1, 2, 3],
        'map': {'a': true},
        'not a geopoint': {
          'latitude': 45.5122,
          'longitude': -122.6587,
          'foo': 'bar'
        }
      };

      jsonObjects.forEach((key, value) {
        test(key, () => _testRoundTrip(value));
      });
    });

    test('custom object', () {
      expect(() => jsify(_TestClass()), throwsArgumentError);
    });

    test('custom object with toJson', () {
      expect(() => jsify(_TestClassWithToJson()), throwsArgumentError);
    });

    test('geopoint', () {
      var value = {'latitude': 45.5122, 'longitude': -122.6587};
      var js = jsify(value);
      var roundTrip = dartify(js);
      expect(roundTrip, const TypeMatcher<GeoPoint>());
    });
  });
}

class _TestClass {}

class _TestClassWithToJson {
  Object toJson() => const {};
}
