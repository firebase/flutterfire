import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockFieldValue extends Mock implements FieldValuePlatform {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group("$FieldValuePlatform()", () {
    test("serverDelegates", () {
      expect(FieldValuePlatform.serverDelegates(null), isNull);

      final mockFieldValue = MockFieldValue();
      FieldValuePlatform.serverDelegates({"item": mockFieldValue});
      verify(mockFieldValue.instance);
    });
  });
}
