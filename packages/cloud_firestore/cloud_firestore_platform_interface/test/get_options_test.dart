// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('$GetOptions', () {
    test('throws if source is a null value', () {
      expect(() => GetOptions(source: null), throwsAssertionError);
    });

    test('provides a default source if none provided', () {
      expect(GetOptions().source, equals(Source.serverAndCache));
    });
  });
}
