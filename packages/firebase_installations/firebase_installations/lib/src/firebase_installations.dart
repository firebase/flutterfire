// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_installations;

class FirebaseInstallations extends FirebasePluginPlatform {
  FirebaseInstallations._({required this.app})
      : super(app.name, 'plugins.flutter.io/firebase_installations');

  // Cached and lazily loaded instance of [FirebaseInstallationsPlatform] to avoid
  // creating a [MethodChannelFirebaseInstallations] when not needed or creating an
  // instance with the default app before a user specifies an app.
  FirebaseInstallationsPlatform? _delegatePackingProperty;

  /// Returns the underlying [FirebaseFunctionsPlatform] delegate for this
  /// [FirebaseFunctions] instance. This is useful for testing purposes only.
  FirebaseInstallationsPlatform get _delegate {
    return _delegatePackingProperty ??=
        FirebaseInstallationsPlatform.instanceFor(app: app);
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

  /// Returns an instance using a specified [FirebaseApp] & region.
  static FirebaseInstallations instanceFor({FirebaseApp? app, String? region}) {
    app ??= Firebase.app();
    region ??= 'us-central1';
    String cachedKey = '${app.name}_$region';

    if (_cachedInstances.containsKey(cachedKey)) {
      return _cachedInstances[cachedKey]!;
    }

    FirebaseInstallations newInstance = FirebaseInstallations._(app: app);
    _cachedInstances[cachedKey] = newInstance;

    return newInstance;
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
  Stream<String> onIdChange() {
    return _delegate.onIdChange();
  }
}
