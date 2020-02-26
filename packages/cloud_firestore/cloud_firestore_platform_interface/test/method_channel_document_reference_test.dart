// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cloud_firestore_platform_interface/src/method_channel/method_channel_document_reference.dart';
import 'package:cloud_firestore_platform_interface/src/method_channel/method_channel_field_value_factory.dart';

import 'test_common.dart';

void main() {
  initializeMethodChannel();

  group("$MethodChannelDocumentReference()", () {
    MethodChannelDocumentReference _documentReference;
    FieldValuePlatform mockFieldValue;
    setUp(() {
      _documentReference = MethodChannelDocumentReference(
          FirestorePlatform.instance, [kCollectionId, kDocumentId]);
      mockFieldValue =
          FieldValuePlatform(MethodChannelFieldValueFactory().increment(2.0));
    });

    test("setData", () async {
      _assertSetDataMethodCalled(_documentReference, null, null);
      _assertSetDataMethodCalled(_documentReference, true, null);
      _assertSetDataMethodCalled(_documentReference, false, null);
      _assertSetDataMethodCalled(_documentReference, false, mockFieldValue);
    });

    test("updateData", () async {
      bool isMethodCalled = false;
      final Map<String, dynamic> data = {
        "test": "test",
        "fieldValue": mockFieldValue
      };
      handleMethodCall((call) {
        if (call.method == "DocumentReference#updateData") {
          isMethodCalled = true;
          expect(call.arguments["data"]["test"], equals(data["test"]));
        }
      });
      await _documentReference.updateData(data);
      expect(isMethodCalled, isTrue,
          reason: "DocumentReference.updateData was not called");
    });

    test("get", () async {
      await _assertGetMethodCalled(_documentReference, null, "default");
      await _assertGetMethodCalled(_documentReference, Source.cache, "cache");
      await _assertGetMethodCalled(_documentReference, Source.server, "server");
      await _assertGetMethodCalled(
          _documentReference, Source.serverAndCache, "default");
    });

    test("delete", () async {
      bool isMethodCalled = false;
      handleMethodCall((call) {
        if (call.method == "DocumentReference#delete") {
          isMethodCalled = true;
        }
      });
      await _documentReference.delete();
      expect(isMethodCalled, isTrue,
          reason: "DocumentReference.delete was not called");
    });

    test("snapshots", () async {
      bool isMethodCalled = false;
      handleMethodCall((call) {
        if (call.method == "DocumentReference#addSnapshotListener") {
          isMethodCalled = true;
        }
        return 0;
      });
      _documentReference.snapshots().listen((_) {});
      expect(isMethodCalled, isTrue,
          reason: "DocumentReference.addSnapshotListener was not called");
    });
  });
}

void _assertGetMethodCalled(DocumentReferencePlatform documentReference,
    Source source, String expectedSourceString) async {
  bool isMethodCalled = false;
  handleMethodCall((call) {
    if (call.method == "DocumentReference#get") {
      isMethodCalled = true;
      expect(call.arguments["source"], equals(expectedSourceString));
    }
    return {
      "path": "test/test",
      "data": {},
      "metadata": {"hasPendingWrites": false, "isFromCache": false}
    };
  });
  if (source != null) {
    await documentReference.get(source: source);
  } else {
    await documentReference.get();
  }
  expect(isMethodCalled, isTrue,
      reason: "DocumentReference.get was not called");
}

void _assertSetDataMethodCalled(DocumentReferencePlatform documentReference,
    bool expectedMergeValue, FieldValuePlatform fieldValue) async {
  bool isMethodCalled = false;
  final Map<String, dynamic> data = {"test": "test"};
  if (fieldValue != null) {
    data.addAll({"fieldValue": fieldValue});
  }
  handleMethodCall((call) {
    if (call.method == "DocumentReference#setData") {
      isMethodCalled = true;
      expect(call.arguments["data"]["test"], equals(data["test"]));
      expect(call.arguments["options"]["merge"], expectedMergeValue ?? false);
    }
  });
  if (expectedMergeValue == null) {
    await documentReference.setData(data);
  } else {
    await documentReference.setData(data, merge: expectedMergeValue);
  }
  expect(isMethodCalled, isTrue,
      reason: "DocumentReference.setData was not called");
}
