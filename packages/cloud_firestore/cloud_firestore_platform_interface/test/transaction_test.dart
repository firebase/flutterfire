import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:cloud_firestore_platform_interface/src/method_channel/method_channel_transaction.dart';

import 'test_common.dart';

class MockDocumentReference extends Mock implements DocumentReferencePlatform {}

class MockFiledValue extends Mock implements FieldValuePlatform {}

const _kTransactionId = 1022;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final mockFieldValue = MockFiledValue();

  group("$MethodChannelTransaction()", () {
    TransactionPlatform transaction;
    final mockDocumentReference = MockDocumentReference();
    when(mockDocumentReference.path).thenReturn("$kCollectionId/$kDocumentId");
    setUp(() {
      transaction =
          MethodChannelTransaction(_kTransactionId, FirestorePlatform.instance.app.name);
      reset(mockFieldValue);
      when(mockFieldValue.type).thenReturn(FieldValueType.incrementDouble);
      when(mockFieldValue.value).thenReturn(2.0);
    });

    test("get", () async {
      bool isMethodCalled = false;
      handleMethodCall((call) {
        if (call.method == "Transaction#get") {
          isMethodCalled = true;
          expect(call.arguments["transactionId"], equals(_kTransactionId));
        }
      });
      await transaction.get(mockDocumentReference);
      expect(isMethodCalled, isTrue, reason: "Transaction.get was not called");
    });

    test("delete", () async {
      bool isMethodCalled = false;
      handleMethodCall((call) {
        if (call.method == "Transaction#delete") {
          isMethodCalled = true;
          expect(call.arguments["transactionId"], equals(_kTransactionId));
        }
      });
      await transaction.delete(mockDocumentReference);
      expect(isMethodCalled, isTrue,
          reason: "Transaction.delete was not called");
    });

    test("update", () async {
      bool isMethodCalled = false;
      final Map<String, dynamic> data = {
        "test": "test",
        "fieldValue": mockFieldValue
      };
      handleMethodCall((call) {
        if (call.method == "Transaction#update") {
          isMethodCalled = true;
          expect(call.arguments["transactionId"], equals(_kTransactionId));
          expect(call.arguments["data"]["test"], equals(data["test"]));
        }
      });
      await transaction.update(mockDocumentReference, data);
      verify(mockFieldValue.instance);
      expect(isMethodCalled, isTrue,
          reason: "Transaction#update was not called");
    });

    test("set", () async {
      bool isMethodCalled = false;
      final Map<String, dynamic> data = {
        "test": "test",
        "fieldValue": mockFieldValue
      };
      handleMethodCall((call) {
        if (call.method == "Transaction#set") {
          isMethodCalled = true;
          expect(call.arguments["transactionId"], equals(_kTransactionId));
          expect(call.arguments["data"]["test"], equals(data["test"]));
        }
      });
      await transaction.set(mockDocumentReference, data);
      verify(mockFieldValue.instance);
      expect(isMethodCalled, isTrue, reason: "Transaction#set was not called");
    });
  });
}
