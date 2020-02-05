// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cloud_firestore_platform_interface/src/method_channel/method_channel_query.dart';

import 'test_common.dart';

const _kQueryPath = "test/collection";

class TestQuery extends MethodChannelQuery {
  TestQuery._()
      : super(
            firestore: FirestorePlatform.instance,
            pathComponents: _kQueryPath.split("/"));
}

void main() {
  initializeMethodChannel();

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
