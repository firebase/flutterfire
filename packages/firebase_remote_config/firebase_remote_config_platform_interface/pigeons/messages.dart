// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeon/messages.pigeon.dart',
    // We export in the lib folder to expose the class to other packages.
    dartTestOut: 'lib/src/pigeon/test_api.dart',
    javaOut:
        '../firebase_remote_config/android/src/main/java/io/flutter/plugins/firebase/firebaseremoteconfig/GeneratedAndroidFirebaseRemoteConfig.java',
    javaOptions: JavaOptions(
      package: 'io.flutter.plugins.firebase.remoteconfig',
      className: 'GeneratedAndroidFirebaseRemoteConfig',
    ),
    objcHeaderOut: '../firebase_remote_config/ios/Classes/messages.g.h',
    objcSourceOut: '../firebase_remote_config/ios/Classes/messages.g.m',
    cppHeaderOut: '../firebase_remote_config/windows/messages.g.h',
    cppSourceOut: '../firebase_remote_config/windows/messages.g.cpp',
    cppOptions: CppOptions(namespace: 'firebase_remote_config_windows'),
    copyrightHeader: 'pigeons/copyright.txt',
  ),
)

/// ValueSource defines the possible sources of a config parameter value.
enum PigeonValueSource {
  /// The value was defined by a static constant.
  valueStatic,

  /// The value was defined by default config.
  valueDefault,

  /// The value was defined by fetched config.
  valueRemote,
}

enum PigeonRemoteConfigFetchStatus {
  /// Indicates instance has not yet attempted a fetch.
  noFetchYet,

  /// Indicates the last fetch attempt succeeded.
  success,

  /// Indicates the last fetch attempt failed.
  failure,

  /// Indicates the last fetch attempt was rate-limited.
  throttle
}

class PigeonRemoteConfigSettings {
  PigeonRemoteConfigSettings({
    required this.fetchTimeout,
    required this.minimumFetchInterval,
  });

  final int fetchTimeout;

  final int minimumFetchInterval;
}

class PigeonRemoteConfigValue {
  PigeonRemoteConfigValue(this.value, this.source);

  List<int?>? value;

  /// Indicates at which source this value came from.
  final PigeonValueSource source;
}

class PigeonFirebaseApp {
  const PigeonFirebaseApp({
    required this.appName,
    required this.tenantId,
  });

  final String appName;
  final String? tenantId;
}

@HostApi(dartHostTestHandler: 'TestFirebaseRemoteConfigHostApi')
abstract class FirebaseRemoteConfigHostApi {
  @async
  bool activate(PigeonFirebaseApp app);

  @async
  void ensureInitialized(PigeonFirebaseApp app);

  @async
  void fetch(PigeonFirebaseApp app);

  @async
  bool fetchAndActivate(PigeonFirebaseApp app);

  Map<String, PigeonRemoteConfigValue> getAll(PigeonFirebaseApp app);

  bool getBool(
    PigeonFirebaseApp app,
    String key,
  );

  int getInt(
    PigeonFirebaseApp app,
    String key,
  );

  double getDouble(
    PigeonFirebaseApp app,
    String key,
  );

  String getString(
    PigeonFirebaseApp app,
    String key,
  );

  PigeonRemoteConfigValue getValue(
    PigeonFirebaseApp app,
    String key,
  );

  @async
  void setConfigSettings(
    PigeonFirebaseApp app,
    PigeonRemoteConfigSettings remoteConfigSettings,
  );

  @async
  void setDefaults(
    PigeonFirebaseApp app,
    Map<String, Object> defaultParameters,
  );
}
