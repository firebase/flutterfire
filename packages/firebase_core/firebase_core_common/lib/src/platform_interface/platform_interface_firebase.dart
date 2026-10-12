// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../default_firebase_app_name.dart';
import '../firebase_exception.dart';
import '../firebase_options.dart';
import 'platform_interface_firebase_app.dart';

/// The interface that implementations of `firebase_core` must extend.
///
/// Platform implementations should extend this class rather than implement it
/// as `firebase_core` does not consider newly added methods to be breaking
/// changes. Extending this class (using `extends`) ensures that the subclass
/// will get the default implementation, while platform implementations that
/// `implements` this interface will be broken by newly added
/// [FirebasePlatform] methods.
abstract class FirebasePlatform extends PlatformInterface {
  // ignore: public_member_api_docs
  FirebasePlatform() : super(token: _token);

  static final Object _token = Object();

  /// Whether a [FirebasePlatform] implementation has been registered.
  ///
  /// Implementations register themselves by setting [FirebasePlatform.instance],
  /// usually from their `registerWith` method which is called by the Flutter
  /// plugin registrant (or manually when running outside of Flutter).
  static bool get isRegistered => _instance != null;

  /// The default instance of [FirebasePlatform] to use.
  ///
  /// Platform-specific plugins should set this with their own class
  /// that extends [FirebasePlatform] when they register themselves.
  ///
  /// Throws a [FirebaseException] if no implementation has been registered yet.
  /// On Flutter, `firebase_core` registers its `MethodChannel` implementation
  /// before the first usage of the `Firebase` API. Other platforms must call
  /// the `registerWith` method of their implementation, for example
  /// `FirebaseCoreWeb.registerWith(null)` on web.
  static FirebasePlatform get instance {
    final FirebasePlatform? instance = _instance;

    if (instance == null) {
      throw FirebaseException(
        plugin: 'core',
        code: 'no-platform-implementation',
        message: 'No Firebase Core platform implementation has been '
            'registered.\n\nIf you are using Flutter, this usually means that '
            'the platform you are running on is not supported, or that '
            '`Firebase.initializeApp()` has not been called yet.\n\nIf you are '
            'not using Flutter, register your implementation manually, for '
            'example by calling `FirebaseCoreWeb.registerWith(null)` on web.',
      );
    }

    return instance;
  }

  static FirebasePlatform? _instance;

  static set instance(FirebasePlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  /// Returns all initialized [FirebaseApp] instances.
  List<FirebaseAppPlatform> get apps {
    throw UnimplementedError('apps has not been implemented.');
  }

  /// Initializes a new [FirebaseApp] with the given [name] and [FirebaseOptions].
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) {
    throw UnimplementedError('initializeApp() has not been implemented.');
  }

  /// Returns a Firebase app with the given [name].
  ///
  /// If there is no such app, returns null.
  FirebaseAppPlatform app([String name = defaultFirebaseAppName]) {
    throw UnimplementedError('app() has not been implemented.');
  }
}
