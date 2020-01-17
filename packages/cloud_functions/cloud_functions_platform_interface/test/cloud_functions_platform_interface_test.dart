// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cloud_functions_platform_interface/cloud_functions_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$CloudFunctionsPlatform()', () {
    test('$MethodChannelCloudFunctions is the default instance', () {
      expect(
          CloudFunctionsPlatform.instance, isA<MethodChannelCloudFunctions>());
    });

    test('Cannot be implemented with `implements`', () {
      expect(() {
        CloudFunctionsPlatform.instance = ImplementsCloudFunctionsPlatform();
      }, throwsAssertionError);
    });

    test('Can be extended', () {
      CloudFunctionsPlatform.instance = ExtendsCloudFunctionsPlatform();
    });

    test('Can be mocked with `implements`', () {
      final CloudFunctionsPlatform mock = MocksCloudFunctionsPlatform();
      CloudFunctionsPlatform.instance = mock;
    });
  });
}

class ImplementsCloudFunctionsPlatform extends Mock
    implements CloudFunctionsPlatform {}

class MocksCloudFunctionsPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements CloudFunctionsPlatform {}

class ExtendsCloudFunctionsPlatform extends CloudFunctionsPlatform {}
