// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

typedef Callback = void Function(MethodCall call);

void setupFirebaseAuthMocks([Callback? customHandlers]) {
  TestWidgetsFlutterBinding.ensureInitialized();

  setupFirebaseCoreMocks();
  TestFirebaseAppHostApi.setUp(MockFirebaseAppHostApi());
}

Future<T> neverEndingFuture<T>() async {
  // ignore: literal_only_boolean_expressions
  while (true) {
    await Future.delayed(const Duration(minutes: 5));
  }
}

class MockFirebaseAppHostApi implements TestFirebaseAppHostApi {
  @override
  Future<void> delete(String appName) async {}

  @override
  Future<void> setAutomaticDataCollectionEnabled(
    String appName,
    bool enabled,
  ) async {}

  @override
  Future<void> setAutomaticResourceManagementEnabled(
    String appName,
    bool enabled,
  ) async {}
}
