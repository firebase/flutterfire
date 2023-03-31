import 'package:firebase_storage/firebase_storage.dart';
import 'package:mockito/mockito.dart';
import 'package:uuid/uuid.dart';

class MockReference extends Mock implements Reference {}

class MockStorage extends Mock implements FirebaseStorage {
  static MockStorage instance = MockStorage();

  @override
  Reference ref([String? path]) => MockReference();
}

class MockUUID extends Mock implements Uuid {
  static String value = '1234-5678-9012-3456';

  @override
  String v4({Map<String, dynamic>? options}) => value;
}
