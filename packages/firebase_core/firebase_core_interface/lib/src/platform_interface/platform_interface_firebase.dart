// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../constants.dart';
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

  /// The default instance of [FirebasePlatform] to use.
  ///
  /// Platform-specific plugins should override this with their own class
  /// that extends [FirebasePlatform] when they register themselves.
  ///
  /// If no implementation has registered itself, the first read creates one
  /// with [fallbackInstanceFactory], and throws a [StateError] if that is not
  /// set either.
  ///
  /// On Android, Apple platforms and Windows no implementation registers
  /// itself, so in Flutter apps this throws until the first `Firebase` call
  /// (such as `Firebase.initializeApp()`) or, in tests,
  /// `setupFirebaseCoreMocks()`. Both set [fallbackInstanceFactory] to
  /// `MethodChannelFirebase`.
  static FirebasePlatform get instance =>
      _instance ??= _createFallbackInstance();

  static FirebasePlatform? _instance;

  static set instance(FirebasePlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  /// Creates [instance] when it is read before an implementation has
  /// registered itself.
  ///
  /// For platform implementations only. `firebase_core` sets this to
  /// `MethodChannelFirebase.new` on its first use, as does
  /// `setupFirebaseCoreMocks()`, so Flutter apps use method channels on
  /// platforms without a Dart implementation.
  static FirebasePlatform Function()? fallbackInstanceFactory;

  static FirebasePlatform _createFallbackInstance() {
    final factory = fallbackInstanceFactory;
    if (factory == null) {
      throw StateError(
        'No FirebasePlatform implementation has been registered. In Flutter '
        'apps, call Firebase.initializeApp() first, or setupFirebaseCoreMocks() '
        'in tests. Dart web apps without Flutter must register one first, for '
        'example with FirebaseCoreWeb.registerWith() from firebase_core_js.',
      );
    }
    final instance = factory();
    PlatformInterface.verify(instance, _token);
    return instance;
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
