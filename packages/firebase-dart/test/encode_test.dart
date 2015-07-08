library firebase.test.encode;

import 'package:firebase/src/encode.dart';
import 'package:test/test.dart';

import 'test_shared.dart';

void main() {
  test('monkey', () {
    var encoded = encodeKey(invalidKeyString);
    var decoded = decodeKey(encoded);
    expect(decoded, invalidKeyString);
  });
}
