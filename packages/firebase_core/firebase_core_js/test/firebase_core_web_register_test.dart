// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('browser')
library;

import 'package:firebase_core_interface/firebase_core_interface.dart';
import 'package:firebase_core_js/firebase_core_js.dart';
import 'package:test/test.dart';

void main() {
  test('registerWith registers FirebaseCoreWeb without a registrar', () {
    FirebaseCoreWeb.registerWith();

    expect(FirebasePlatform.instance, isA<FirebaseCoreWeb>());
  });
}
