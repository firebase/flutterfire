import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _kCollectionId = "test";
const _kDocumentId = "document";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("$MethodChannelCollectionReference", () {
    MethodChannelCollectionReference _testCollection;
    setUp(() {
      _testCollection = MethodChannelCollectionReference(
          FirestorePlatform.instance, [_kCollectionId]);
    });
    test("Parent", () {
      expect(_testCollection.parent(), isNull);
      expect(
          MethodChannelCollectionReference(FirestorePlatform.instance,
              [_kCollectionId, _kDocumentId, "test"]).parent().path,
          equals("$_kCollectionId/$_kDocumentId"));
    });
    test("Document", () {
      expect(_testCollection.document().path.split("/").length, equals(2));
      expect(_testCollection.document(_kDocumentId).path.split("/").last,
          equals(_kDocumentId));
    });
    test("Add",() async {
      bool _methodChannelCalled = false;
      MethodChannelFirestore.channel.setMockMethodCallHandler((MethodCall methodCall) async {
        switch(methodCall.method) {
          case "DocumentReference#setData":
            expect(methodCall.arguments["data"]["test"], equals("test"));
            _methodChannelCalled = true;
            break;
          default:
            return;
        }
      });
      await _testCollection.add({"test":"test"});
      expect(_methodChannelCalled,isTrue, reason: "DocumentReference.setData was not called");
    });
  });
}
