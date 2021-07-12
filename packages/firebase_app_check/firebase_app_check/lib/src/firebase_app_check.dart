// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_app_check;

class FirebaseAppCheck extends FirebasePluginPlatform {
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

  /// Activates the Firebase App Check service.
  ///
  /// On web, provide the reCAPTCHA v3 Site Key which can be found in the
  /// Firebase Console. For more information, see
  /// [the Firebase Documentation](https://firebase.google.com/docs/app-check/web).
  Future<void> activate({String? webRecaptchaSiteKey}) {
    return _delegate.activate(webRecaptchaSiteKey: webRecaptchaSiteKey);
  }
}
