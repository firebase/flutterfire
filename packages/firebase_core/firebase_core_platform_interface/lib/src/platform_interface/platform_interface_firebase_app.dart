// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of '../../firebase_core_platform_interface.dart';

/// A class storing the name and options of a Firebase app.
///
/// This is created as a result of calling [FirebasePlatform.initializeApp].
class FirebaseAppPlatform extends PlatformInterface {
  // ignore: public_member_api_docs
  FirebaseAppPlatform(this.name, this.options) : super(token: _token);

  static final Object _token = Object();

  // ignore: public_member_api_docs
  static void verify(FirebaseAppPlatform instance) {
    PlatformInterface.verify(instance, _token);
  }

  /// The name of this Firebase app.
  final String name;

  /// Returns the [FirebaseOptions] that this app was configured with.
  final FirebaseOptions options;

  /// Returns whether this instance is the default Firebase app.
  bool get _isDefault => name == defaultFirebaseAppName;

  /// Returns true if automatic data collection is enabled for this app.
  bool get isAutomaticDataCollectionEnabled {
    throw UnimplementedError(
      'isAutomaticDataCollectionEnabled has not been implemented.',
    );
  }

  /// Deletes the current FirebaseApp.
  Future<void> delete() async {
    throw UnimplementedError('delete() has not been implemented.');
  }

  /// Sets whether automatic data collection is enabled or disabled for this app.
  ///
  /// It is possible to check whether data collection is currently enabled via
  /// the [FirebaseAppPlatform.isAutomaticDataCollectionEnabled] property.
  Future<void> setAutomaticDataCollectionEnabled(bool enabled) async {
    throw UnimplementedError(
      'setAutomaticDataCollectionEnabled() has not been implemented.',
    );
  }

  /// Sets whether automatic resource management is enabled or disabled for this app.
  Future<void> setAutomaticResourceManagementEnabled(bool enabled) async {
    throw UnimplementedError(
      'setAutomaticResourceManagementEnabled() has not been implemented.',
    );
  }

  /// The signed-in user's ID token, or `null` when the Auth SDK isn't linked
  /// into the app or nobody is signed in.
  ///
  /// Throws a [FirebaseException] for plugin `core` when the Auth SDK fails to
  /// produce a token; its message is the SDK's and its code is
  /// `auth-token-failed`.
  ///
  /// For Firebase packages that attach the token to their own requests, as the
  /// native Functions SDK does; not for app code.
  Future<String?> getAuthIdToken() async {
    throw UnimplementedError('getAuthIdToken() has not been implemented.');
  }

  /// The App Check SDK's answer, or `null` when it isn't linked into the app.
  ///
  /// Asking before App Check is activated returns the SDK's placeholder token
  /// with [AppCheckInteropToken.error] set, as the native SDKs report it.
  /// With [limitedUse], the SDK issues a limited-use token instead of a cached
  /// one.
  ///
  /// For Firebase packages that attach the token to their own requests, as the
  /// native Functions SDK does; not for app code.
  Future<AppCheckInteropToken?> getAppCheckToken({
    bool limitedUse = false,
  }) async {
    throw UnimplementedError('getAppCheckToken() has not been implemented.');
  }

  /// The FCM registration token, or `null` when Messaging isn't linked into
  /// the app or has no token.
  ///
  /// Never prompts the user and, on Apple and web, never generates a token.
  /// Messaging only serves the default app, so other apps get `null`.
  /// On Android, where fetching may hit the network, a failure throws a
  /// [FirebaseException] for plugin `core` with code `messaging-token-failed`.
  ///
  /// For Firebase packages that attach the token to their own requests, as the
  /// native Functions SDK does; not for app code.
  Future<String?> getMessagingToken() async {
    throw UnimplementedError('getMessagingToken() has not been implemented.');
  }

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FirebaseAppPlatform) return false;
    return other.name == name && other.options == options;
  }

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => Object.hash(name, options);

  @override
  String toString() => '$FirebaseAppPlatform($name)';
}
