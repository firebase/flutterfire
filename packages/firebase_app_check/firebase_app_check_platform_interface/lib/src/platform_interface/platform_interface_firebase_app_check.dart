// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:meta/meta.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import '../method_channel/method_channel_firebase_app_check.dart';

abstract class FirebaseAppCheckPlatform extends PlatformInterface {
  /// The [FirebaseApp] this instance was initialized with.
  FirebaseAppCheckPlatform({this.appInstance}) : super(token: _token);

  /// Create an instance using [app] using the existing implementation
  factory FirebaseAppCheckPlatform.instanceFor({required FirebaseApp app}) {
    // Only the default app is supported on App Check.
    assert(app.name == defaultFirebaseAppName);
    return FirebaseAppCheckPlatform.instance.setInitialValues();
  }

  /// The [FirebaseApp] this instance was initialized with.
  @protected
  final FirebaseApp? appInstance;

  /// Create an instance using [app]
  static final Object _token = Object();

  /// Returns the [FirebaseApp] for the current instance.
  FirebaseApp get app {
    if (appInstance == null) {
      return Firebase.app();
    }

    return appInstance!;
  }

  static FirebaseAppCheckPlatform? _instance;

  /// The current default [FirebaseAppCheckPlatform] instance.
  ///
  /// It will always default to [FirebaseAppCheckPlatform]
  /// if no other implementation was provided.
  static FirebaseAppCheckPlatform get instance {
    return _instance ??= MethodChannelFirebaseAppCheck(app: Firebase.app());
  }

  /// Sets the [FirebaseAppCheckPlatform.instance]
  static set instance(FirebaseAppCheckPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Activates the Firebase App Check service.
  ///
  /// On web, provide the reCAPTCHA v3 Site Key which can be found in the
  /// Firebase Console. For more information, see
  /// [the Firebase Documentation](https://firebase.google.com/docs/app-check/web?authuser=0).
  Future<void> activate({String? webRecaptchaSiteKey}) {
    throw UnimplementedError('activate() is not implemented');
  }

  /// Sets any initial values on the instance.
  ///
  /// Platforms with Method Channels can provide constant values to be available
  /// before the instance has initialized to prevent any unnecessary async
  /// calls.
  @protected
  FirebaseAppCheckPlatform setInitialValues() {
    throw UnimplementedError('setInitialValues() is not implemented');
  }
}
