import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("$MethodChannelFieldValueFactory()", (){
    final MethodChannelFieldValueFactory factory = MethodChannelFieldValueFactory();
    test("arrayRemove", (){
      final actual = factory.arrayRemove([1]);
      expect(actual.type, equals(FieldValueType.arrayRemove));
    });
    test("arrayUnion", (){
      final actual = factory.arrayUnion([1]);
      expect(actual.type, equals(FieldValueType.arrayUnion));
    });
    test("delete", (){
      final actual = factory.delete();
      expect(actual.type, equals(FieldValueType.delete));
    });
    test("increment", (){
      final actualInt = factory.increment(1);
      expect(actualInt.type, equals(FieldValueType.incrementInteger));
      final actualDouble = factory.increment(1.0);
      expect(actualDouble.type, equals(FieldValueType.incrementDouble));
    });
    test("serverTimestamp", (){
      final actual = factory.serverTimestamp();
      expect(actual.type, equals(FieldValueType.serverTimestamp));
    });
  });
}