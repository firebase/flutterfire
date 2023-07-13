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
class PigeonFirebaseApp {
  const PigeonFirebaseApp({
    required this.appName,
  });

  final String appName;
}

@HostApi(dartHostTestHandler: 'TestFirebaseFirestoreHostApi')
abstract class FirebaseFirestoreHostApi {
  @async
  String registerIdTokenListener(
    PigeonFirebaseApp app,
  );
}
