// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IndexMode', () {
    test('recommended has expected name', () {
      expect(IndexMode.recommended.name, 'recommended');
    });
  });

  group('ExecuteOptions', () {
    test('default indexMode is recommended', () {
      const options = ExecuteOptions();
      expect(options.indexMode, IndexMode.recommended);
    });
  });
}
