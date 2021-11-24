// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_performance_platform_interface/firebase_performance_platform_interface.dart';
import 'package:firebase_performance_platform_interface/src/method_channel/method_channel_http_metric.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mock.dart';

//todo this needs updating to platform interface stuff
void main() {
  setupFirebasePerformanceMocks();

  late TestMethodChannelHttpMetric httpMetric;
  const int kHandle = 23;
  const String kUrl = 'https://test-url.com';
  const HttpMethod kMethod = HttpMethod.Get;

  late FirebaseApp app;
  group('$FirebasePerformancePlatform()', () {
    setUpAll(() async {
      app = await Firebase.initializeApp();

      httpMetric = TestMethodChannelHttpMetric(kHandle, kUrl, kMethod);
    });
  });
}

class TestFirebasePerformancePlatform extends FirebasePerformancePlatform {
  TestFirebasePerformancePlatform(FirebaseApp app) : super(appInstance: app);
}

class TestMethodChannelHttpMetric extends MethodChannelHttpMetric {
  TestMethodChannelHttpMetric(handle, url, method) : super(handle, url, method);
}
