// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';
import 'package:flutter/services.dart';

/// The entry point for accessing a Messaging.
///
/// You can get an instance by calling [FirebaseMessaging.instance].
class MethodChannelFirebaseMessaging extends FirebaseMessagingPlatform {
  /// Create an instance of [MethodChannelFirebaseFirestore] with optional [FirebaseApp]
  MethodChannelFirebaseMessaging({FirebaseApp app}) : super(appInstance: app) {
    if (_initialized) return;
    channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        default:
          throw UnimplementedError("${call.method} has not been implemented");
      }
    });
    _initialized = true;
  }

  static bool _initialized = false;

  /// The [MethodChannel] used to communicate with the native plugin
  static MethodChannel channel = MethodChannel(
    'plugins.flutter.io/firebase_messaging',
  );
}
