// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: one_member_abstracts

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeon/messages.pigeon.dart',
    // We export in the lib folder to expose the class to other packages.
    dartTestOut: 'test/pigeon/test_api.dart',
    javaOut:
        '../cloud_firestore/android/src/main/java/io/flutter/plugins/firebase/firestore/GeneratedAndroidFirebaseFirestore.java',
    javaOptions: JavaOptions(
      package: 'io.flutter.plugins.firebase.firestore',
      className: 'GeneratedAndroidFirebaseFirestore',
    ),
    objcHeaderOut: '../cloud_firestore/ios/Classes/messages.g.h',
    objcSourceOut: '../cloud_firestore/ios/Classes/messages.g.m',
  ),
)
class PigeonFirebaseSettings {
  const PigeonFirebaseSettings({
    required this.persistenceEnabled,
    required this.host,
    required this.sslEnabled,
    required this.cacheSizeBytes,
    required this.ignoreUndefinedProperties,
  });

  final bool? persistenceEnabled;
  final String? host;
  final bool? sslEnabled;
  final int? cacheSizeBytes;
  final bool ignoreUndefinedProperties;
}

class PigeonFirebaseApp {
  const PigeonFirebaseApp({
    required this.appName,
    required this.settings,
  });

  final String appName;
  final PigeonFirebaseSettings settings;
}

@HostApi(dartHostTestHandler: 'TestFirebaseFirestoreHostApi')
abstract class FirebaseFirestoreHostApi {
  @async
  String loadBundle(
    PigeonFirebaseApp app,
    Uint8List bundle,
  );
}
