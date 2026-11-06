// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

class _OtherFirebasePlatform extends FirebasePlatform {}

void main() {
  setUp(() => FirebasePlatform.fallbackInstanceFactory = null);

  test('registerWith makes MethodChannelFirebase the fallback', () {
    MethodChannelFirebase.registerWith();

    expect(
      FirebasePlatform.fallbackInstanceFactory?.call(),
      isA<MethodChannelFirebase>(),
    );
  });

  test('registerWith keeps a fallback that is already set', () {
    FirebasePlatform.fallbackInstanceFactory = _OtherFirebasePlatform.new;

    MethodChannelFirebase.registerWith();

    expect(
      FirebasePlatform.fallbackInstanceFactory?.call(),
      isA<_OtherFirebasePlatform>(),
    );
  });
}
