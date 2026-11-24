// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeon/messages.pigeon.dart',
    dartPackageName: 'firebase_app_installations_platform_interface',
    kotlinOut:
        '../firebase_app_installations/android/src/main/kotlin/io/flutter/plugins/firebase/installations/firebase_app_installations/GeneratedAndroidFirebaseAppInstallations.g.kt',
    kotlinOptions: KotlinOptions(
      package:
          'io.flutter.plugins.firebase.installations.firebase_app_installations',
    ),
    swiftOut:
        '../firebase_app_installations/ios/firebase_app_installations/Sources/firebase_app_installations/FirebaseAppInstallationsMessages.g.swift',
    copyrightHeader: 'pigeons/copyright.txt',
  ),
)
@HostApi()
abstract class FirebaseAppInstallationsHostApi {
  @asyncCallback
  void delete(String appName);

  @asyncCallback
  String getId(String appName);

  @asyncCallback
  String getToken(String appName, bool forceRefresh);

  @asyncCallback
  String registerIdChangeListener(String appName);
}
