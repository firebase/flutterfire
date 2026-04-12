// Copyright 2025 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeon/messages.pigeon.dart',
    dartPackageName: 'firebase_app_check_platform_interface',
    kotlinOut:
        '../firebase_app_check/android/src/main/kotlin/io/flutter/plugins/firebase/appcheck/GeneratedAndroidFirebaseAppCheck.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'io.flutter.plugins.firebase.appcheck',
    ),
    swiftOut:
        '../firebase_app_check/ios/firebase_app_check/Sources/firebase_app_check/FirebaseAppCheckMessages.g.swift',
    cppHeaderOut: '../firebase_app_check/windows/messages.g.h',
    cppSourceOut: '../firebase_app_check/windows/messages.g.cpp',
    cppOptions: CppOptions(namespace: 'firebase_app_check_windows'),
    copyrightHeader: 'pigeons/copyright.txt',
  ),
)
@HostApi(dartHostTestHandler: 'TestFirebaseAppCheckHostApi')
abstract class FirebaseAppCheckHostApi {
  @async
  void activate(
    String appName,
    String? androidProvider,
    String? appleProvider,
    String? debugToken,
    String? windowsProvider,
  );

  @async
  String? getToken(String appName, bool forceRefresh);

  @async
  void setTokenAutoRefreshEnabled(
    String appName,
    bool isTokenAutoRefreshEnabled,
  );

  @async
  String registerTokenListener(String appName);

  @async
  String getLimitedUseAppCheckToken(String appName);
}

// Dart-side handler invoked by C++ when the Firebase SDK needs a fresh App
// Check token on Windows. Implementations call getWindowsAppCheckToken (a
// Cloud Function with enforceAppCheck:false) and return the minted token
// string. The C++ side blocks until the Future resolves, then hands the token
// to the Firebase SDK, which attaches it to every subsequent Firestore request.
@FlutterApi()
abstract class FirebaseAppCheckFlutterApi {
  @async
  String getCustomToken();
}
