// Copyright 2025 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

class AppCheckWebProvider {
  AppCheckWebProvider({required this.providerName});
  
  String providerName; // 'reCAPTCHA' or 'debug'
}

class AppCheckAndroidProvider {
  AppCheckAndroidProvider({required this.providerName});
  
  String providerName; // 'safetyNet', 'playIntegrity', or 'debug'
}

class AppCheckAppleProvider {
  AppCheckAppleProvider({required this.providerName});
  
  String providerName; // 'deviceCheck', 'appAttest', 'debug', or 'appAttestWithDeviceCheckFallback'
}

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeon/messages.pigeon.dart',
    dartPackageName: 'firebase_app_check_platform_interface',
    kotlinOut:
        '../firebase_app_check/android/src/main/kotlin/io/flutter/plugins/firebase/firebaseappcheck/GeneratedAndroidFirebaseAppCheck.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'io.flutter.plugins.firebase.firebaseappcheck',
    ),
    swiftOut:
        '../firebase_app_check/ios/firebase_app_check/Sources/firebase_app_check/FirebaseAppCheckMessages.g.swift',
    cppHeaderOut: '../firebase_app_check/windows/messages.g.h',
    cppSourceOut: '../firebase_app_check/windows/messages.g.cpp',
    cppOptions: CppOptions(namespace: 'firebase_app_check_windows'),
    copyrightHeader: 'pigeons/copyright.txt',
  ),
)
class AppCheckPigeonSettings {
  AppCheckPigeonSettings({
    required this.webProvider,
    required this.androidProvider,
    required this.appleProvider,
  });

  AppCheckWebProvider webProvider;
  AppCheckAndroidProvider androidProvider;
  AppCheckAppleProvider appleProvider;
}

@HostApi(dartHostTestHandler: 'TestFirebaseAppCheckHostApi')
abstract class FirebaseAppCheckHostApi {
  @async
  void activate(String appName, AppCheckWebProvider webProvider, AppCheckAndroidProvider androidProvider, AppCheckAppleProvider appleProvider);

  @async
  String? getToken(String appName, bool forceRefresh);

  @async
  void setTokenAutoRefreshEnabled(String appName, bool isTokenAutoRefreshEnabled);

  @async
  String getLimitedUseToken(String appName);
}