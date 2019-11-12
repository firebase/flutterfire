// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:meta/meta.dart' show visibleForTesting;

import 'src/firebase_options.dart';
import 'src/method_channel_firebase_core.dart';
import 'src/platform_firebase_app.dart';

export 'src/firebase_options.dart';
export 'src/method_channel_firebase_core.dart';
export 'src/platform_firebase_app.dart';

/// The interface that implementations of `firebase_core` must extend.
///
/// Platform implementations should extend this class rather than implement it
/// as `firebase_core` does not consider newly added methods to be breaking
/// changes. Extending this class (using `extends`) ensures that the subclass
/// will get the default implementation, while platform implementations that
/// `implements` this interface will be broken by newly added
/// [FirebaseCorePlatform] methods.
abstract class FirebaseCorePlatform {
  /// Only mock implementations should set this to `true`.
  ///
  /// Mockito mocks implement this class with `implements` which is forbidden
  /// (see class docs). This property provides a backdoor for mocks to skip the
  /// verification that the class isn't implemented with `implements`.
  @visibleForTesting
  bool get isMock => false;

  /// The default instance of [FirebaseCorePlatform] to use.
  ///
  /// Platform-specific plugins should override this with their own class
  /// that extends [FirebaseCorePlatform] when they register themselves.
  ///
  /// Defaults to [MethodChannelFirebaseCore].
  static FirebaseCorePlatform get instance => _instance;

  static FirebaseCorePlatform _instance = MethodChannelFirebaseCore();

  // TODO(amirh): Extract common platform interface logic.
  // https://github.com/flutter/flutter/issues/43368
  static set instance(FirebaseCorePlatform instance) {
    if (!instance.isMock) {
      try {
        instance._verifyProvidesDefaultImplementations();
      } on NoSuchMethodError catch (_) {
        throw AssertionError(
            'Platform interfaces must not be implemented with `implements`');
      }
    }
    _instance = instance;
  }

  /// This method ensures that [FirebaseCorePlatform] isn't implemented with `implements`.
  ///
  /// See class docs for more details on why using `implements` to implement
  /// [FirebaseCorePlatform] is forbidden.
  ///
  /// This private method is called by the [instance] setter, which should fail
  /// if the provided instance is a class implemented with `implements`.
  void _verifyProvidesDefaultImplementations() {}

  /// Returns the data for the Firebase app with the given [name].
  ///
  /// If there is no such app, returns null.
  Future<PlatformFirebaseApp> appNamed(String name) {
    throw UnimplementedError('appNamed() has not been implemented.');
  }

  /// Configures the app named [name] with the given [options].
  Future<void> configure(String name, FirebaseOptions options) {
    throw UnimplementedError('configure() has not been implemented.');
  }

  /// Returns a list of all extant Firebase app instances.
  ///
  /// If there are no live Firebase apps, returns `null`.
  Future<List<PlatformFirebaseApp>> allApps() {
    throw UnimplementedError('allApps() has not been implemented.');
  }
}
