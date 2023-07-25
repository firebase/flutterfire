// ignore_for_file: require_trailing_commas
// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_app_check;

class FirebaseAppCheck extends FirebasePluginPlatform {
  static Map<String, FirebaseAppCheck> _firebaseAppCheckInstances = {};

  FirebaseAppCheck._({required this.app})
      : super(app.name, 'plugins.flutter.io/firebase_app_check');

  /// Cached instance of [FirebaseAppCheck];
  static FirebaseAppCheck? _instance;

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
    _instance ??= FirebaseAppCheck._(app: Firebase.app());
    return _instance!;
  }

  /// Returns an instance using a specified [FirebaseApp].
  static FirebaseAppCheck instanceFor({required FirebaseApp app}) {
    return _firebaseAppCheckInstances.putIfAbsent(app.name, () {
      return FirebaseAppCheck._(app: app);
    });
  }

  /// Activates the Firebase App Check service.
  ///
  /// On web, provide the reCAPTCHA v3 Site Key which can be found in the
  /// Firebase Console.
  ///
  /// On Android, the default provider is "play integrity". If you wish to set the provider to "safety net" or "debug", you may set the `androidProvider` property using the `AndroidProvider` enum
  ///
  /// On iOS or macOS, the default provider is "device check". If you wish to set the provider to "app attest", "debug" or "app attest with fallback to device check"
  /// ("app attest" is only available on iOS 14.0+, macOS 14.0+), you may set the `appleProvider` property using the `AppleProvider` enum
  ///
  /// For more information, see [the Firebase Documentation](https://firebase.google.com/docs/app-check)
  Future<void> activate({
    String? webRecaptchaSiteKey,
    AndroidProvider androidProvider = AndroidProvider.playIntegrity,
    AppleProvider appleProvider = AppleProvider.deviceCheck,
  }) {
    return _delegate.activate(
      webRecaptchaSiteKey: webRecaptchaSiteKey,
      androidProvider: androidProvider,
      appleProvider: appleProvider,
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
