import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

const _kCollectionId = "test";
const _kDocumentId = "document";

class TestDocumentReference extends DocumentReference {
  TestDocumentReference._()
      : super(FirestorePlatform.instance, [_kCollectionId, _kDocumentId]);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group("$DocumentReference()", () {
    test("Parent", () {
      final document = TestDocumentReference._();
      final parent = document.parent();
      final parentPath = parent.path;
      expect(parent, isInstanceOf<CollectionReference>());
      expect(parentPath, equals(_kCollectionId));
    });

    test("documentID", () {
      final document = TestDocumentReference._();
      expect(document.documentID, equals(_kDocumentId));
    });

    test("Path", () {
      final document = TestDocumentReference._();
      expect(document.path, equals("$_kCollectionId/$_kDocumentId"));
    });

    test("Collection", () {
      final document = TestDocumentReference._();
      expect(document.collection("extra").path,
          equals("$_kCollectionId/$_kDocumentId/extra"));
    });
  });
}
