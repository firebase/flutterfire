@TestOn('browser')
import 'package:firebase/src/utils.dart';

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
        'map': {'a': true}
      };

      jsonObjects.forEach((key, value) {
        test(key, () => _testRoundTrip(value));
      });
    });

    test('custom object', () {
      expect(() => jsify(new _TestClass()), throwsArgumentError);
    });

    test('custom object with toJson', () {
      expect(() => jsify(new _TestClassWithToJson()), throwsArgumentError);
    });
  });
}

class _TestClass {}

class _TestClassWithToJson {
  Object toJson() => const {};
}
