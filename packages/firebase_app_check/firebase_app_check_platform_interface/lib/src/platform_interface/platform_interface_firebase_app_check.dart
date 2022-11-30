// ignore_for_file: require_trailing_commas
// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_app_check_platform_interface/firebase_app_check_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:meta/meta.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class FirebaseAppCheckPlatform extends PlatformInterface {
  /// The [FirebaseApp] this instance was initialized with.
  FirebaseAppCheckPlatform({this.appInstance}) : super(token: _token);

  /// Create an instance using [app] using the existing implementation
  factory FirebaseAppCheckPlatform.instanceFor({required FirebaseApp app}) {
    return FirebaseAppCheckPlatform.instance
        .delegateFor(app: app)
        .setInitialValues();
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
    return _instance ??= MethodChannelFirebaseAppCheck.instance;
  }

  /// Sets the [FirebaseAppCheckPlatform.instance]
  static set instance(FirebaseAppCheckPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  /// Activates the Firebase App Check service.
  ///
  /// On web, provide the reCAPTCHA v3 Site Key which can be found in the
  /// Firebase Console. For more information, see
  /// [the Firebase Documentation](https://firebase.google.com/docs/app-check/web).
  ///
  /// On Android, the default provider is "play integrity". If you wish to set the provider to "safety net" or "debug", you may set the `androidProvider` property using the `AndroidProvider` enum
  /// For more information, see [the Firebase Documentation](https://firebase.google.com/docs/app-check)
  Future<void> activate(
      {String? webRecaptchaSiteKey, AndroidProvider? androidProvider}) {
    throw UnimplementedError('activate() is not implemented');
  }

  /// Get the current App Check token. Attaches to the most recent in-flight
  /// request if one is present. Returns null if no token is present and no
  /// token requests are in-flight.
  ///
  /// If `forceRefresh` is true, will always try to fetch a fresh token. If
  /// false, will use a cached token if found in storage.
  Future<String?> getToken(bool forceRefresh) async {
    throw UnimplementedError('getToken() is not implemented');
  }

  /// If true, the SDK automatically refreshes App Check tokens as needed.
  Future<void> setTokenAutoRefreshEnabled(bool isTokenAutoRefreshEnabled) {
    throw UnimplementedError('setTokenAutoRefreshEnabled() is not implemented');
  }

  /// Registers a listener to changes in the token state.
  Stream<String?> get onTokenChange {
    throw UnimplementedError('tokenChanges() is not implemented');
  }

  /// Enables delegates to create new instances of themselves if a none default
  /// [FirebaseApp] instance is required by the user.
  @protected
  FirebaseAppCheckPlatform delegateFor({required FirebaseApp app}) {
    throw UnimplementedError('delegateFor() is not implemented');
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
