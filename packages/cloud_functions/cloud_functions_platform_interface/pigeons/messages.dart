// Copyright 2025 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeon/messages.pigeon.dart',
    dartTestOut: 'test/pigeon/test_api.dart',
    dartPackageName: 'cloud_functions_platform_interface',
    kotlinOut:
        '../cloud_functions/android/src/main/kotlin/io/flutter/plugins/firebase/functions/GeneratedAndroidCloudFunctions.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'io.flutter.plugins.firebase.functions',
    ),
    swiftOut:
        '../cloud_functions/ios/cloud_functions/Sources/cloud_functions/CloudFunctionsMessages.g.swift',
    cppHeaderOut: '../cloud_functions/windows/messages.g.h',
    cppSourceOut: '../cloud_functions/windows/messages.g.cpp',
    cppOptions: CppOptions(namespace: 'cloud_functions_windows'),
    copyrightHeader: 'pigeons/copyright.txt',
  ),
)
@HostApi(dartHostTestHandler: 'TestCloudFunctionsHostApi')
abstract class CloudFunctionsHostApi {
  @async
  Object? call(Map<String, Object?> arguments);

  @async
  void registerEventChannel(Map<String, Object> arguments);
}
