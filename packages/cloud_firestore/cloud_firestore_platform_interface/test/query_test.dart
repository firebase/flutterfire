import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cloud_firestore_platform_interface/src/method_channel/method_channel_query.dart';

const _kQueryPath = "test/collection";

class TestQuery extends MethodChannelQuery {
  TestQuery._()
      : super(
            firestore: FirestorePlatform.instance,
            pathComponents: _kQueryPath.split("/"));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group("$QueryPlatform()", () {
    test("parameters", () {
      _hasDefaultParameters(TestQuery._().parameters);
    });

    test("reference", () {
      final testQuery = TestQuery._();
      final actualCollection = testQuery.reference();
      expect(actualCollection, isInstanceOf<CollectionReferencePlatform>());
      expect(actualCollection.path, equals(_kQueryPath));
    });

    test("limit", () {
      final testQuery = TestQuery._().limit(1);
      expect(testQuery.parameters["limit"], equals(1));
      _hasDefaultParameters(testQuery.parameters);
    });
  });
}

void _hasDefaultParameters(Map<String, dynamic> input) {
  expect(input["where"], equals([]));
  expect(input["orderBy"], equals([]));
}
