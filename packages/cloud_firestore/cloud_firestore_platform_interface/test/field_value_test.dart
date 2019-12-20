import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockFieldValue extends Mock implements FieldValueInterface {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group("$FieldValue()", () {
    test("ServeDelegates", () {
      expect(FieldValue.serverDelegates(null), isNull);

      final mockFieldValue = MockFieldValue();
      FieldValue.serverDelegates({"item": mockFieldValue});
      verify(mockFieldValue.instance);
    });
  });
}
