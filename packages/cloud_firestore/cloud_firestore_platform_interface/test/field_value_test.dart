// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:cloud_firestore_platform_interface/src/method_channel/utils/maps.dart';

class MockFieldValue extends Mock implements FieldValuePlatform {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group("$unwrapFieldValueInterfaceToPlatformType()", () {
    test("unwrapFieldValueInterfaces", () {
      expect(unwrapFieldValueInterfaceToPlatformType(null), isNull);

      final mockFieldValue = MockFieldValue();
      unwrapFieldValueInterfaceToPlatformType({"item": mockFieldValue});
      verify(mockFieldValue.instance);
    });
  });
}
