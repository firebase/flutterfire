// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:meta/meta.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../method_channel/method_channel_firebase_auth.dart';

/// The interface that implementations of `firebase_auth` must extend.
///
/// Platform implementations should extend this class rather than implement it
/// as `firebase_auth` does not consider newly added methods to be breaking
/// changes. Extending this class (using `extends`) ensures that the subclass
/// will get the default implementation, while platform implementations that
/// `implements` this interface will be broken by newly added
/// [FirebaseAuthPlatform] methods.
abstract class FirebaseAuthPlatform extends PlatformInterface {
  /// The [FirebaseApp] this instance was initialized with.
  @protected
  final FirebaseApp appInstance;

  /// Create an instance using [app]
  FirebaseAuthPlatform({this.appInstance}) : super(token: _token);

  /// Returns the [FirebaseApp] for the current instance.
  FirebaseApp get app {
    if (appInstance == null) {
      return Firebase.app();
    }

    return appInstance;
  }

  static final Object _token = Object();

  /// Create an instance using [app] using the existing implementation
  factory FirebaseAuthPlatform.instanceFor(
      {FirebaseApp app, Map<dynamic, dynamic> pluginConstants}) {
    return FirebaseAuthPlatform.instance.delegateFor(app: app).setInitialValues(
        languageCode: pluginConstants['APP_LANGUAGE_CODE'],
        currentUser: pluginConstants['APP_CURRENT_USER'] == null
            ? null
            : Map<String, dynamic>.from(pluginConstants['APP_CURRENT_USER']));
  }

  /// The current default [FirebaseAuthPlatform] instance.
  ///
  /// It will always default to [MethodChannelFiresbaseAuth]
  /// if no other implementation was provided.
  static FirebaseAuthPlatform get instance {
    if (_instance == null) {
      _instance = MethodChannelFirebaseAuth.instance;
    }

    return _instance;
  }

  static FirebaseAuthPlatform _instance;

  /// Sets the [FirebaseAuthPlatform.instance]
  static set instance(FirebaseAuthPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Enables delegates to create new instances of themselves if a none default
  /// [FirebaseApp] instance is required by the user.
  @protected
  FirebaseAuthPlatform delegateFor({FirebaseApp app}) {
    throw UnimplementedError('delegateFor() is not implemented');
  }

  /// Sets any initial values on the instance.
  ///
  /// Platforms with Method Channels can provide constant values to be available
  /// before the instance has initialized to prevent any unnecessary async calls.
  @protected
  FirebaseAuthPlatform setInitialValues({
    Map<String, dynamic> currentUser,
    String languageCode,
  }) {
    throw UnimplementedError('setInitialValues() is not implemented');
  }

  UserPlatform get currentUser {
    throw UnimplementedError("currentUser is not implemented");
  }

  String get languageCode {
    throw UnimplementedError("languageCode is not implemented");
  }

  void setCurrentUser(UserPlatform userPlatform) {
    throw UnimplementedError("setCurrentUser() is not implemented");
  }

  /// Applies a verification code sent to the user by email or
  /// other out-of-band mechanism.
  Future<void> applyActionCode(String code) {
    throw UnimplementedError("applyActionCode() is not implemented");
  }

  /// Applies a verification code sent to the user by email or
  /// other out-of-band mechanism.
  Future<ActionCodeInfo> checkActionCode(String code) {
    throw UnimplementedError("applyActionCode() is not implemented");
  }

  /// Completes the password reset process, given a confirmation code and new password.
  Future<void> confirmPasswordReset(String code, String newPassword) {
    throw UnimplementedError("confirmPasswordReset() is not implemented");
  }

  Future<UserCredentialPlatform> createUserWithEmailAndPassword(
      String email, String password) {
    throw UnimplementedError(
        "createUserWithEmailAndPassword() is not implemented");
  }

  /// Gets the list of possible sign in methods for the given email address.
  Future<List<String>> fetchSignInMethodsForEmail(String email) {
    throw UnimplementedError('fetchSignInMethodsForEmail() is not implemented');
  }

  Future<UserCredentialPlatform> getRedirectResult() {
    throw UnimplementedError('getRedirectResult() is not implemented');
  }

  /// Checks if an incoming link is a sign-in with email link.
  bool isSignInWithEmailLink(String emailLink) {
    return (emailLink.contains('mode=signIn') ||
            emailLink.contains('mode%3DsignIn')) &&
        (emailLink.contains('oobCode=') || emailLink.contains('oobCode%3D'));
  }

  /// Notifies about changes to the user's sign-in state (such as sign-in or sign-out).
  Stream<UserPlatform> authStateChanges() {
    throw UnimplementedError('authStateChanges() is not implemented');
  }

  /// Notifies about changes to the user's sign-in state (such as sign-in or sign-out)
  /// and also token refresh events.
  Stream<UserPlatform> idTokenChanges() {
    throw UnimplementedError('idTokenChanges() is not implemented');
  }

  Stream<UserPlatform> userChanges() {
    throw UnimplementedError('userChanges() is not implemented');
  }

  /// Sends a password reset email to the given [email].
  Future<void> sendPasswordResetEmail(String email,
      [ActionCodeSettings actionCodeSettings]) {
    throw UnimplementedError('sendPasswordResetEmail() is not implemented');
  }

  /// Sends a sign in with email link to provided email address.
  Future<void> sendSignInWithEmailLink(
      String email, ActionCodeSettings actionCodeSettings) {
    throw UnimplementedError('sendSignInWithEmailLink() is not implemented');
  }

  /// When set to null, the default Firebase Console language setting is applied.
  ///
  /// The language code will propagate to email action templates (password reset,
  /// email verification and email change revocation), SMS templates for phone
  /// authentication, reCAPTCHA verifier and OAuth popup/redirect operations
  /// provided the specified providers support localization with the language
  /// code specified.
  Future<void> setLanguageCode(String languageCode) {
    throw UnimplementedError('setLanguageCode() is not implemented');
  }

  Future<void> setSettings({bool appVerificationDisabledForTesting}) {
    throw UnimplementedError('setSettings() is not implemented');
  }

  /// Changes the current type of persistence on the current Auth instance for
  /// the currently saved Auth session and applies this type of persistence for
  /// future sign-in requests, including sign-in with redirect requests. This
  /// will return a promise that will resolve once the state finishes copying
  /// from one type of storage to the other. Calling a sign-in method after
  /// changing persistence will wait for that persistence change to complete
  /// before applying it on the new Auth state.
  ///
  /// This makes it easy for a user signing in to specify whether their session
  /// should be remembered or not. It also makes it easier to never persist the
  /// Auth state for applications that are shared by other users or have sensitive data.
  ///
  /// This is only supported on web based platforms.
  Future<void> setPersistence(Persistence persistence) async {
    throw UnimplementedError('setPersistence() is not implemented');
  }

  /// Asynchronously creates and becomes an anonymous user.
  ///
  /// If there is already an anonymous user signed in, that user will be
  /// returned instead. If there is any other existing user signed in, that
  /// user will be signed out.
  ///
  /// **Important**: You must enable Anonymous accounts in the Auth section
  /// of the Firebase console before being able to use them.
  Future<UserCredentialPlatform> signInAnonymously() async {
    throw UnimplementedError('signInAnonymously() is not implemented');
  }

  /// Asynchronously signs in to Firebase with the given 3rd-party credentials
  /// (e.g. a Facebook login Access Token, a Google ID Token/Access Token pair,
  /// etc.) and returns additional identity provider data.
  ///
  /// If successful, it also signs the user in into the app and updates
  /// the [onAuthStateChanged] stream.
  ///
  /// If the user doesn't have an account already, one will be created automatically.
  ///
  /// **Important**: You must enable the relevant accounts in the Auth section
  /// of the Firebase console before being able to use them.
  Future<UserCredentialPlatform> signInWithCredential(
      AuthCredential credential) async {
    throw UnimplementedError('signInWithCredential() is not implemented');
  }

  /// Tries to sign in a user with a given Custom Token [token].
  ///
  /// If successful, it also signs the user in into the app and updates
  /// the [onAuthStateChanged] stream.
  ///
  /// Use this method after you retrieve a Firebase Auth Custom Token from your server.
  ///
  /// If the user identified by the [uid] specified in the token doesn't
  /// have an account already, one will be created automatically.
  ///
  /// Read how to use Custom Token authentication and the cases where it is
  /// useful in [the guides](https://firebase.google.com/docs/auth/android/custom-auth).
  Future<UserCredentialPlatform> signInWithCustomToken(String token) async {
    throw UnimplementedError('signInWithCustomToken() is not implemented');
  }

  Future<UserCredentialPlatform> signInWithEmailAndPassword(
      String email, String password) async {
    throw UnimplementedError('signInWithEmailAndPassword() is not implemented');
  }

  /// Signs in using an email address and email sign-in link.
  Future<UserCredentialPlatform> signInWithEmailLink(
      String email, String emailLink) async {
    throw UnimplementedError('signInWithEmailLink() is not implemented');
  }

  Future<ConfirmationResultPlatform> signInWithPhoneNumber(
      String phoneNumber, RecaptchaVerifierPlatform applicationVerifier) async {
    throw UnimplementedError('signInWithPhoneNumber() is not implemented');
  }

  Future<UserCredentialPlatform> signInWithPopup(AuthProvider provider) {
    throw UnimplementedError('signInWithPopup() is not implemented');
  }

  Future<void> signInWithRedirect(AuthProvider provider) {
    throw UnimplementedError('signInWithRedirect() is not implemented');
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    throw UnimplementedError('signOut() is not implemented');
  }

  /// Checks a password reset code sent to the user by email or other out-of-band mechanism.
  ///
  /// Returns the user's email address if valid.
  Future<String> verifyPasswordResetCode(String code) {
    throw UnimplementedError('verifyPasswordResetCode() is not implemented');
  }

  Future<void> verifyPhoneNumber(
      {@required String phoneNumber,
      @required PhoneVerificationCompleted verificationCompleted,
      @required PhoneVerificationFailed verificationFailed,
      @required PhoneCodeSent codeSent,
      @required PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout,
      Duration timeout = const Duration(seconds: 30),
      int forceResendingToken,
      bool requireSmsValidation}) {
    throw UnimplementedError('verifyPhoneNumber() is not implemented');
  }
}
