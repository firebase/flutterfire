// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library firebase_auth_platform_interface;

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart' show required, visibleForTesting;

part 'src/method_channel_firebase_auth.dart';
part 'src/types.dart';

/// The interface that implementations of `firebase_auth` must extend.
///
/// Platform implementations should extend this class rather than implement it
/// as `firebase_auth` does not consider newly added methods to be breaking
/// changes. Extending this class (using `extends`) ensures that the subclass
/// will get the default implementation, while platform implementations that
/// `implements` this interface will be broken by newly added
/// [FirebaseAuthPlatform] methods.
abstract class FirebaseAuthPlatform {
  /// Only mock implementations should set this to `true`.
  ///
  /// Mockito mocks implement this class with `implements` which is forbidden
  /// (see class docs). This property provides a backdoor for mocks to skip the
  /// verification that the class isn't implemented with `implements`.
  @visibleForTesting
  bool get isMock => false;

  /// The default instance of [FirebaseAuthPlatform] to use.
  ///
  /// Platform-specific plugins should override this with their own class
  /// that extends [FirebaseAuthPlatform] when they register themselves.
  ///
  /// Defaults to [MethodChannelFirebaseAuth].
  static FirebaseAuthPlatform get instance => _instance;

  static FirebaseAuthPlatform _instance = MethodChannelFirebaseAuth();

  // TODO(amirh): Extract common platform interface logic.
  // https://github.com/flutter/flutter/issues/43368
  static set instance(FirebaseAuthPlatform instance) {
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

  /// This method ensures that [FirebaseAuthPlatform] isn't implemented with `implements`.
  ///
  /// See class docs for more details on why using `implements` to implement
  /// [FirebaseAuthPlatform] is forbidden.
  ///
  /// This private method is called by the [instance] setter, which should fail
  /// if the provided instance is a class implemented with `implements`.
  void _verifyProvidesDefaultImplementations() {}

  /// Returns the current user.
  Future<PlatformUser> getCurrentUser(String app) {
    throw UnimplementedError('getCurrentUser() is not implemented');
  }

  /// Sign in anonymously and return the auth result.
  Future<PlatformAuthResult> signInAnonymously(String app) {
    throw UnimplementedError('signInAnonymously() is not implemented');
  }

  /// Create a user with the given [email] and [password].
  Future<PlatformAuthResult> createUserWithEmailAndPassword(
    String app,
    String email,
    String password,
  ) {
    throw UnimplementedError(
        'createUserWithEmailAndPassword() is not implemented');
  }

  /// Retrieve a list of available sign in methods for the given [email].
  Future<List<String>> fetchSignInMethodsForEmail(String app, String email) {
    throw UnimplementedError('fetchSignInMethodsForEmail() is not implemented');
  }

  /// Sends a password reset email to the given [email].
  Future<void> sendPasswordResetEmail(String app, String email) {
    throw UnimplementedError('sendPasswordResetEmail() is not implemented');
  }

  /// Sends a sign in with email link to provided email address.
  Future<void> sendLinkToEmail(
    String app, {
    @required String email,
    @required String url,
    @required bool handleCodeInApp,
    @required String iOSBundleID,
    @required String androidPackageName,
    @required bool androidInstallIfNotAvailable,
    @required String androidMinimumVersion,
  }) {
    throw UnimplementedError('sendLinkToEmail() is not implemented');
  }

  /// Completes to `true` if the given [link] is an email sign-in link.
  Future<bool> isSignInWithEmailLink(String app, String link) {
    throw UnimplementedError('isSignInWithEmailLink() is not implemented');
  }

  /// Signs in with the given [email] and [link].
  Future<PlatformAuthResult> signInWithEmailAndLink(
    String app,
    String email,
    String link,
  ) {
    throw UnimplementedError('signInWithEmailAndLink() is not implemented');
  }

  /// Sends an email verification to the current user.
  Future<void> sendEmailVerification(String app) {
    throw UnimplementedError('sendEmailVerification() is not implemented');
  }

  /// Refreshes the current user, if signed in.
  Future<void> reload(String app) {
    throw UnimplementedError('reload() is not implemented');
  }

  /// Delete the current user and logs them out.
  Future<void> delete(String app) {
    throw UnimplementedError('delete() is not implemented');
  }

  /// Signs in with the given [credential].
  Future<PlatformAuthResult> signInWithCredential(
    String app,
    AuthCredential credential,
  ) {
    throw UnimplementedError('signInWithCredential() is not implemented');
  }

  /// Signs in the with the given custom [token].
  Future<PlatformAuthResult> signInWithCustomToken(String app, String token) {
    throw UnimplementedError('signInWithCustomToken() is not implemented');
  }

  /// Signs the current user out of the app.
  Future<void> signOut(String app) {
    throw UnimplementedError('signOut() is not implemented');
  }

  /// Returns a token used to identify the user to a Firebase service.
  Future<PlatformIdTokenResult> getIdToken(String app, bool refresh) {
    throw UnimplementedError('getIdToken() is not implemented');
  }

  /// Re-authenticates the current user with the given [credential].
  Future<PlatformAuthResult> reauthenticateWithCredential(
    String app,
    AuthCredential credential,
  ) {
    throw UnimplementedError(
        'reauthenticalWithCredential() is not implemented');
  }

  /// Links the current user with the given [credential].
  Future<PlatformAuthResult> linkWithCredential(
    String app,
    AuthCredential credential,
  ) {
    throw UnimplementedError('linkWithCredential() is not implemented');
  }

  /// Unlinks the current user with the given [provider].
  Future<void> unlinkFromProvider(String app, String provider) {
    throw UnimplementedError('unlinkFromProvider() is not implemented');
  }

  /// Updates the current user's email to the given [email].
  Future<void> updateEmail(String app, String email) {
    throw UnimplementedError('updateEmail() is not implemented');
  }

  /// Update the current user's phone number with the given [phoneAuthCredential].
  Future<void> updatePhoneNumberCredential(
    String app,
    PhoneAuthCredential phoneAuthCredential,
  ) {
    throw UnimplementedError(
        'updatePhoneNumberCredential() is not implemented');
  }

  /// Update the current user's password to the given [password].
  Future<void> updatePassword(String app, String password) {
    throw UnimplementedError('updatePassword() is not implemented');
  }

  /// Update the current user's profile.
  Future<void> updateProfile(
    String app, {
    String displayName,
    String photoUrl,
  }) {
    throw UnimplementedError('updateProfile() is not implemented');
  }

  /// Sets the current language code.
  Future<void> setLanguageCode(String app, String language) {
    throw UnimplementedError('setLanguageCode() is not implemented');
  }

  /// Creates a new stream which emits the current user on signOut and signIn.
  Stream<PlatformUser> onAuthStateChanged(String app) {
    throw UnimplementedError('onAuthStateChanged() is not implemented');
  }

  /// Verify the current user's phone number.
  Future<void> verifyPhoneNumber(
    String app, {
    @required String phoneNumber,
    @required Duration timeout,
    int forceResendingToken,
    @required PhoneVerificationCompleted verificationCompleted,
    @required PhoneVerificationFailed verificationFailed,
    @required PhoneCodeSent codeSent,
    @required PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout,
  }) {
    throw UnimplementedError('verifyPhoneNumber() is not implemented');
  }

  /// Completes the password reset process, given a confirmation code and new password.
  Future<void> confirmPasswordReset(
    String app,
    String oobCode,
    String newPassword,
  ) {
    throw UnimplementedError('confirmPasswordReset() is not implemented');
  }
}
