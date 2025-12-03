// Copyright 2025 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeon/messages.pigeon.dart',
    dartTestOut: 'test/pigeon/test_api.dart',
    dartPackageName: 'firebase_app_installations_platform_interface',
    javaOut:
        '../firebase_app_installations/android/src/main/java/io/flutter/plugins/firebase/installations/GeneratedAndroidFirebaseAppInstallations.java',
    javaOptions: JavaOptions(
      package: 'io.flutter.plugins.firebase.installations',
      className: 'GeneratedAndroidFirebaseAppInstallations',
    ),
    objcHeaderOut:
        '../firebase_app_installations/ios/firebase_app_installations/Sources/firebase_app_installations/firebase_app_installations_messages.g.h',
    objcSourceOut:
        '../firebase_app_installations/ios/firebase_app_installations/Sources/firebase_app_installations/firebase_app_installations_messages.g.m',
    swiftOut:
        '../firebase_app_installations/ios/firebase_app_installations/Sources/firebase_app_installations/FirebaseAppInstallationsMessages.g.swift',
    cppHeaderOut: '../firebase_app_installations/windows/messages.g.h',
    cppSourceOut: '../firebase_app_installations/windows/messages.g.cpp',
    cppOptions: CppOptions(namespace: 'firebase_app_installations_windows'),
    copyrightHeader: 'pigeons/copyright.txt',
  ),
)
class AppInstallationsPigeonSettings {
  const AppInstallationsPigeonSettings({
    required this.persistenceEnabled,
    required this.forceRefreshOnSignIn,
    required this.forceRefreshOnTokenChange,
    required this.forceRefreshOnAppUpdate,
  });

  final bool persistenceEnabled;
  final bool forceRefreshOnSignIn;
  final bool forceRefreshOnTokenChange;
  final bool forceRefreshOnAppUpdate;
}

class AppInstallationsPigeonFirebaseApp {
  const AppInstallationsPigeonFirebaseApp({
    required this.appName,
  });

  final String appName;
}

@HostApi(dartHostTestHandler: 'TestFirebaseAppInstallationsHostApi')
abstract class FirebaseAppInstallationsHostApi {
  @async
  void initializeApp(AppInstallationsPigeonFirebaseApp app,
      AppInstallationsPigeonSettings settings);

  @async
  void delete(AppInstallationsPigeonFirebaseApp app);

  @async
  String getId(AppInstallationsPigeonFirebaseApp app);

  @async
  String getToken(AppInstallationsPigeonFirebaseApp app, bool forceRefresh);

  @async
  void onIdChange(AppInstallationsPigeonFirebaseApp app, String newId);
}

@FlutterApi()
abstract class FirebaseAppInstallationsFlutterApi {
  @async
  String registerIdTokenListener(AppInstallationsPigeonFirebaseApp app);
}
