// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_common.dart';

const _kCollectionId = "test";
const _kDocumentId = "document";

class TestDocumentReference extends DocumentReferencePlatform {
  TestDocumentReference._()
      : super(FirestorePlatform.instance, [_kCollectionId, _kDocumentId]);
}

void main() {
  initializeMethodChannel();

  group("$DocumentReferencePlatform()", () {
    test("Parent", () {
      final document = TestDocumentReference._();
      final parent = document.parent();
      final parentPath = parent.path;
      expect(parent, isInstanceOf<CollectionReferencePlatform>());
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
