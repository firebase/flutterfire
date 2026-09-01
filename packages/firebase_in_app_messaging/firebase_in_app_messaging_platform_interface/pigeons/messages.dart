// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeon/messages.pigeon.dart',
    dartTestOut: 'test/pigeon/test_api.dart',
    dartPackageName: 'firebase_in_app_messaging_platform_interface',
    kotlinOut:
        '../firebase_in_app_messaging/android/src/main/kotlin/io/flutter/plugins/firebase/inappmessaging/GeneratedAndroidFirebaseInAppMessaging.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'io.flutter.plugins.firebase.inappmessaging',
    ),
    swiftOut:
        '../firebase_in_app_messaging/ios/firebase_in_app_messaging/Sources/firebase_in_app_messaging/FirebaseInAppMessagingMessages.g.swift',
    copyrightHeader: 'pigeons/copyright.txt',
  ),
)
@HostApi(dartHostTestHandler: 'TestFirebaseInAppMessagingHostApi')
abstract class FirebaseInAppMessagingHostApi {
  @async
  void triggerEvent(String appName, String eventName);

  @async
  void setMessagesSuppressed(String appName, bool suppress);

  @async
  void setAutomaticDataCollectionEnabled(String appName, bool enabled);
}
