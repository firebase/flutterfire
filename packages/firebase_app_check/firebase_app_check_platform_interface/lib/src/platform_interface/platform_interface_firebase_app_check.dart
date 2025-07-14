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
  /// ## Platform Configuration
  ///
  /// **Web**: Provide the reCAPTCHA v3 Site Key using `webProvider`, which can be
  /// found in the Firebase Console.
  ///
  /// **Android**: The default provider is "play integrity". Use `providerAndroid`
  /// to configure alternative providers such as "safety net", debug providers, or
  /// custom implementations via `AndroidAppCheckProvider`.
  ///
  /// **iOS/macOS**: The default provider is "device check". Use `providerApple`
  /// to configure alternative providers such as "app attest", debug providers, or
  /// "app attest with fallback to device check" via `AppleAppCheckProvider`.
  /// Note: App Attest is only available on iOS 14.0+ and macOS 14.0+.
  ///
  /// ## Migration Notice
  ///
  /// The `androidProvider` and `appleProvider` parameters will be deprecated
  /// in a future release. Use `providerAndroid` and `providerApple` instead,
  /// which support the new provider classes including `AndroidDebugProvider`
  /// and `AppleDebugProvider` for passing debug tokens directly.
  ///
  /// For more information, see [the Firebase Documentation](https://firebase.google.com/docs/app-check)
  Future<void> activate({
    WebProvider? webProvider,
    @Deprecated(
      'Use providerAndroid instead. '
      'This parameter will be removed in a future major release.',
    )
    AndroidProvider? androidProvider,
    @Deprecated(
      'Use providerApple instead. '
      'This parameter will be removed in a future major release.',
    )
    AppleProvider? appleProvider,
    AndroidAppCheckProvider? providerAndroid,
    AppleAppCheckProvider? providerApple,
  }) {
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

  /// Requests a limited-use Firebase App Check token. This method should be used only
  /// if you need to authorize requests to a non-Firebase backend.
  //
  // Returns limited-use tokens that are intended for use with your non-Firebase backend
  // endpoints that are protected with Replay Protection. This method does not affect
  // the token generation behavior of the `getToken()` method.
  Future<String> getLimitedUseToken() {
    throw UnimplementedError('getLimitedUseToken() is not implemented');
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
