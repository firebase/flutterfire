// ignore_for_file: require_trailing_commas
// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of '../firebase_app_check.dart';

class FirebaseAppCheck extends FirebasePluginPlatform {
  static Map<String, FirebaseAppCheck> _firebaseAppCheckInstances = {};

  FirebaseAppCheck._({required this.app})
      : super(app.name, 'plugins.flutter.io/firebase_app_check');

  /// The [FirebaseApp] for this current [FirebaseAppCheck] instance.
  FirebaseApp app;

  // Cached and lazily loaded instance of [FirebaseAppCheckPlatform] to avoid
  // creating a [MethodChannelFirebaseAppCheck] when not needed or creating an
  // instance with the default app before a user specifies an app.
  FirebaseAppCheckPlatform? _delegatePackingProperty;

  /// Returns the underlying delegate implementation.
  ///
  /// If called and no [_delegatePackingProperty] exists, it will first be
  /// created and assigned before returning the delegate.
  FirebaseAppCheckPlatform get _delegate {
    _delegatePackingProperty ??= FirebaseAppCheckPlatform.instanceFor(
      app: app,
    );

    return _delegatePackingProperty!;
  }

  /// Returns an instance using the default [FirebaseApp].
  static FirebaseAppCheck get instance {
    FirebaseApp defaultAppInstance = Firebase.app();

    return FirebaseAppCheck.instanceFor(app: defaultAppInstance);
  }

  /// Returns an instance using a specified [FirebaseApp].
  static FirebaseAppCheck instanceFor({required FirebaseApp app}) {
    return _firebaseAppCheckInstances.putIfAbsent(app.name, () {
      return FirebaseAppCheck._(app: app);
    });
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
    @Deprecated(
      'Use providerWeb instead. '
      'This parameter will be removed in a future major release.',
    )
    WebProvider? webProvider,
    WebProvider? providerWeb,
    @Deprecated(
      'Use providerAndroid instead. '
      'This parameter will be removed in a future major release.',
    )
    AndroidProvider androidProvider = AndroidProvider.playIntegrity,
    @Deprecated(
      'Use providerApple instead. '
      'This parameter will be removed in a future major release.',
    )
    AppleProvider appleProvider = AppleProvider.deviceCheck,
    AndroidAppCheckProvider providerAndroid =
        const AndroidPlayIntegrityProvider(),
    AppleAppCheckProvider providerApple = const AppleDeviceCheckProvider(),
  }) {
    return _delegate.activate(
      webProvider: providerWeb ?? webProvider,
      // ignore: deprecated_member_use
      androidProvider: androidProvider,
      // ignore: deprecated_member_use
      appleProvider: appleProvider,
      providerAndroid: providerAndroid,
      providerApple: providerApple,
    );
  }

  /// Get the current App Check token.
  ///
  /// Attaches to the most recent in-flight request if one is present. Returns
  /// null if no token is present and no token requests are in-flight.
  ///
  /// If `forceRefresh` is true, will always try to fetch a fresh token. If
  /// false, will use a cached token if found in storage.
  Future<String?> getToken([bool? forceRefresh]) async {
    return _delegate.getToken(forceRefresh ?? false);
  }

  /// If true, the SDK automatically refreshes App Check tokens as needed.
  Future<void> setTokenAutoRefreshEnabled(bool isTokenAutoRefreshEnabled) {
    return _delegate.setTokenAutoRefreshEnabled(isTokenAutoRefreshEnabled);
  }

  /// Requests a limited-use Firebase App Check token. This method should be used only
  /// if you need to authorize requests to a non-Firebase backend.
  //
  // Returns limited-use tokens that are intended for use with your non-Firebase backend
  // endpoints that are protected with Replay Protection. This method does not affect
  // the token generation behavior of the `getToken()` method.
  Future<String> getLimitedUseToken() {
    return _delegate.getLimitedUseToken();
  }

  /// Registers a listener to changes in the token state.
  Stream<String?> get onTokenChange {
    return _delegate.onTokenChange;
  }
}
