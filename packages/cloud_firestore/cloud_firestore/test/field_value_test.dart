import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("$FieldValue", () {
    test('equality', () {
      expect(FieldValue.delete() == FieldValue.delete(), isTrue);
      expect(
          FieldValue.serverTimestamp() == FieldValue.serverTimestamp(), isTrue);
      expect(FieldValue.delete() == FieldValue.serverTimestamp(), isFalse);
    });
  });
}
