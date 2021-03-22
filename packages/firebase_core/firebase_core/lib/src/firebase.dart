// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_core;

/// The entry point for accessing Firebase.
class Firebase {
  // Ensures end-users cannot initialize the class.
  Firebase._();

  // Cached & lazily loaded instance of [FirebasePlatform].
  // Avoids a [MethodChannelFirebase] being initialized until the user
  // starts using Firebase.
  // The property is visible for testing to allow tests to set a mock
  // instance directly as a static property since the class is not initialized.
  @visibleForTesting
  // ignore: public_member_api_docs
  static FirebasePlatform? delegatePackingProperty;

  static FirebasePlatform get _delegate {
    return delegatePackingProperty ??= FirebasePlatform.instance;
  }

  /// Returns a list of all [FirebaseApp] instances that have been created.
  static List<FirebaseApp> get apps {
    return _delegate.apps
        .map((app) => FirebaseApp._(app))
        .toList(growable: false);
  }

  /// Initializes a new [FirebaseApp] instance by [name] and [options] and returns
  /// the created app. This method should be called before any usage of FlutterFire plugins.
  ///
  /// The default app instance cannot be initialized here and should be created
  /// using the platform Firebase integration.
  static Future<FirebaseApp> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async {
    FirebaseAppPlatform app = await _delegate.initializeApp(
      name: name,
      options: options,
    );

    return FirebaseApp._(app);
  }

  /// Returns a [FirebaseApp] instance.
  ///
  /// If no name is provided, the default app instance is returned.
  /// Throws if the app does not exist.
  static FirebaseApp app([String name = defaultFirebaseAppName]) {
    FirebaseAppPlatform app = _delegate.app(name);

    return FirebaseApp._(app);
  }

  // TODO(rrousselGit): remove ==/hashCode
  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (other is! Firebase) return false;
    return other.hashCode == hashCode;
  }

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => toString().hashCode;

  @override
  String toString() => '$Firebase';
}
