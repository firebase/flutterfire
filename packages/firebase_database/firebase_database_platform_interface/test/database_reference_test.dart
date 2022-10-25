// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_database_platform_interface/src/method_channel/method_channel_database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MethodChannelDatabase database;

  setUp(() {
    database = MethodChannelDatabase();
  });

  group('DatabaseReference.key', () {
    test('null for root', () {
      final ref = database.ref();
      expect(ref.key, null);
    });

    test('last component of the path for non-root locations', () {
      final ref = database.ref('path/to/value');
      expect(ref.key, 'value');
    });
  });

  group('DatabaseReference.parent', () {
    test('null for root', () {
      final ref = database.ref();
      expect(ref.parent, null);
    });

    test('correct ref for nodes with parents', () {
      final ref = database.ref('path/to/value');
      expect(ref.parent!.key, 'to');
    });
  });
}
