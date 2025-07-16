// Copyright 2025 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeon/messages.pigeon.dart',
    dartPackageName: 'firebase_remote_config_platform_interface',
    kotlinOut:
        '../firebase_remote_config/android/src/main/kotlin/io/flutter/plugins/firebase/firebaseremoteconfig/GeneratedAndroidFirebaseRemoteConfig.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'io.flutter.plugins.firebase.firebaseremoteconfig',
    ),
    swiftOut:
        '../firebase_remote_config/ios/firebase_remote_config/Sources/firebase_remote_config/FirebaseRemoteConfigMessages.g.swift',
    cppHeaderOut: '../firebase_remote_config/windows/messages.g.h',
    cppSourceOut: '../firebase_remote_config/windows/messages.g.cpp',
    cppOptions: CppOptions(namespace: 'firebase_remote_config_windows'),
    copyrightHeader: 'pigeons/copyright.txt',
  ),
)
class RemoteConfigPigeonSettings {
  RemoteConfigPigeonSettings({
    required this.fetchTimeoutSeconds,
    required this.minimumFetchIntervalSeconds,
  });

  int fetchTimeoutSeconds;
  int minimumFetchIntervalSeconds;
}

@HostApi(dartHostTestHandler: 'TestFirebaseRemoteConfigHostApi')
abstract class FirebaseRemoteConfigHostApi {
  @async
  void fetch(String appName);

  @async
  bool fetchAndActivate(String appName);

  @async
  bool activate(String appName);

  @async
  void setConfigSettings(String appName, RemoteConfigPigeonSettings settings);

  @async
  void setDefaults(String appName, Map<String, Object?> defaultParameters);

  @async
  void ensureInitialized(String appName);

  @async
  void setCustomSignals(String appName, Map<String, Object?> customSignals);

  @async
  Map<String, Object?> getAll(String appName);

  @async
  Map<String, Object> getProperties(String appName);
}
