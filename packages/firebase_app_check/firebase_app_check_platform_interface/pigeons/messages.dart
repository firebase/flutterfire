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

/// Carries a minted App Check token plus the wall-clock expiry the Firebase
/// SDK should associate with it. Returning the expiry alongside the token lets
/// backends mint tokens with arbitrary lifetimes (short TTLs for a stricter
/// security posture, longer TTLs for fewer round-trips) without the plugin
/// hardcoding a refresh window.
class CustomAppCheckToken {
  CustomAppCheckToken({
    required this.token,
    required this.expireTimeMillis,
  });

  /// The App Check token string to send with Firebase requests.
  final String token;

  /// Absolute expiry as Unix epoch milliseconds (UTC). The Firebase SDK uses
  /// this to decide when to refresh; a token returned with an expiry in the
  /// past is treated as immediately expired.
  final int expireTimeMillis;
}

/// Dart-side handler invoked by the native plugin when the Firebase SDK needs
/// a fresh App Check token. Implementations typically call a backend service
/// (for example a Cloud Function with `enforceAppCheck: false`) that mints a
/// token using the Firebase Admin SDK. The native side awaits the future,
/// then hands the token to the Firebase SDK, which attaches it to subsequent
/// Firebase backend requests (Firestore, Functions, Storage, Auth, RTDB).
@FlutterApi()
abstract class FirebaseAppCheckFlutterApi {
  @async
  CustomAppCheckToken getCustomToken();
}
