// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:cloud_firestore_platform_interface/src/method_channel/method_channel_transaction.dart';
import 'package:cloud_firestore_platform_interface/src/method_channel/method_channel_field_value_factory.dart';

import 'test_common.dart';

class MockDocumentReference extends Mock implements DocumentReferencePlatform {}

const _kTransactionId = 1022;

void main() {
  initializeMethodChannel();

  final FieldValuePlatform mockFieldValue =
      FieldValuePlatform(MethodChannelFieldValueFactory().increment(2.0));

  group("MethodChannelTransaction()", () {
    TransactionPlatform transaction;
    final mockDocumentReference = MockDocumentReference();
    when(mockDocumentReference.path).thenReturn("$kCollectionId/$kDocumentId");
    setUp(() {
      transaction = MethodChannelTransaction(
          _kTransactionId, FirestorePlatform.instance.app.name);
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
      expect(isMethodCalled, isTrue, reason: "Transaction#set was not called");
    });
  });
}
