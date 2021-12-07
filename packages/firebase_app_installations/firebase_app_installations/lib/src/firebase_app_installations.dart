// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_app_installations;

class FirebaseInstallations extends FirebasePluginPlatform {
  FirebaseInstallations._({required this.app})
      : super(app.name, 'plugins.flutter.io/firebase_app_installations');

  // Cached and lazily loaded instance of [FirebaseAppInstallationsPlatform] to avoid
  // creating a [MethodChannelFirebaseInstallations] when not needed or creating an
  // instance with the default app before a user specifies an app.
  FirebaseAppInstallationsPlatform? _delegatePackingProperty;

  /// Returns the underlying [FirebaseFunctionsPlatform] delegate for this
  /// [FirebaseFunctions] instance. This is useful for testing purposes only.
  FirebaseAppInstallationsPlatform get _delegate {
    return _delegatePackingProperty ??=
        FirebaseAppInstallationsPlatform.instanceFor(app: app);
  }

  /// The [FirebaseApp] for this current [FirebaseInstallations] instance.
  final FirebaseApp app;

  static final Map<String, FirebaseInstallations> _cachedInstances = {};

  /// Returns an instance using the default [FirebaseApp] and region.
  static FirebaseInstallations get instance {
    return FirebaseInstallations.instanceFor(
      app: Firebase.app(),
    );
  }

  /// Returns an instance using a specified [FirebaseApp].
  static FirebaseInstallations instanceFor({required FirebaseApp app}) {
    return _cachedInstances.putIfAbsent(app.name, () {
      return FirebaseInstallations._(app: app);
    });
  }

  /// Deletes the Firebase Installation and all associated data.
  Future<void> delete() {
    return _delegate.delete();
  }

  /// Creates a Firebase Installation if there isn't one for the app and
  /// returns the Installation ID.
  Future<String> getId() {
    return _delegate.getId();
  }

  /// Returns an Authentication Token for the current Firebase Installation.
  Future<String> getToken([bool forceRefresh = false]) {
    return _delegate.getToken(forceRefresh);
  }

  /// Sends a new event via a [Stream] whenever the Installation ID changes.
  Stream<String> get onIdChange {
    return _delegate.onIdChange;
  }
}
