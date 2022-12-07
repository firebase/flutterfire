// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

/// Default error handler that fetches available providers if
/// `account-exists-with-different-credential` was thrown.
///
/// After succesful execution, auth flow should have
/// [DifferentSignInMethodsFound] state.
void defaultOnAuthError(AuthProvider provider, Object error) {
  if (error is! FirebaseAuthException) {
    throw error;
  }

  if (error is FirebaseAuthMultiFactorException) {
    provider.authListener.onMFARequired(error.resolver);
    return;
  }

  if (error.code == 'account-exists-with-different-credential') {
    final email = error.email;
    if (email == null) {
      throw error;
    }

    provider.findProvidersForEmail(email, error.credential);
  }

  throw error;
}

/// An interface that describes authentication process lifecycle.
///
/// See implementers:
/// - [EmailAuthListener]
/// - [EmailLinkAuthListener]
/// - [PhoneAuthListener]
/// - [UniversalEmailSignInListener]
abstract class AuthListener {
  /// Current [AuthProvider] that is being used to authenticate the user.
  AuthProvider get provider;

  /// {@macro ui.auth.auth_controller.auth}
  FirebaseAuth get auth;

  /// Called if an error occured during the authentication process.
  void onError(Object error);

  /// Called right before the authentication process starts.
  void onBeforeSignIn();

  /// Called if the user has successfully signed in.
  void onSignedIn(UserCredential credential);

  /// Called before an attempt to link the credential with currently signed in
  /// user account.
  void onCredentialReceived(AuthCredential credential);

  /// Called if the credential was successfully linked with the user account.
  void onCredentialLinked(AuthCredential credential);

  /// Called before an attempt to fetch available providers for the email.
  void onBeforeProvidersForEmailFetch();

  /// Called when available providers for the email were successfully fetched.
  void onDifferentProvidersFound(
    String email,
    List<String> providers,
    AuthCredential? credential,
  );

  /// Called when the user cancells the sign in process.
  void onCanceled();

  /// Called when the user has to complete MFA.
  void onMFARequired(MultiFactorResolver resolver);
}

/// {@template ui.auth.auth_provider}
/// An interface that all auth providers should implement.
/// Contains shared authentication logic.
/// {@endtemplate}
abstract class AuthProvider<T extends AuthListener, K extends AuthCredential> {
  /// {@macro ui.auth.auth_controller.auth}
  late FirebaseAuth auth;

  /// {@template ui.auth.auth_provider.auth_listener}
  /// An instance of the [AuthListener] that is used to notify about the
  /// current state of the authentication process.
  /// {@endtemplate}
  T get authListener;

  /// {@macro ui.auth.auth_provider.auth_listener}
  set authListener(T listener);

  /// {@template ui.auth.auth_provider.provider_id}
  /// String identifer of the auth provider, for example: `'password'`,
  /// `'phone'` or `'google.com'`.
  /// {@endtemplate}
  String get providerId;

  /// Verifies that an [AuthProvider] is supported on a [platform].
  bool supportsPlatform(TargetPlatform platform);

  /// {@macro ui.auth.auth_provider}
  AuthProvider();

  /// Indicates whether the user should be upgraded and new credential should be
  /// linked.
  bool get shouldUpgradeAnonymous => auth.currentUser?.isAnonymous ?? false;

  /// Signs the user in with the provided [AuthCredential].
  void signInWithCredential(K credential) {
    authListener.onBeforeSignIn();
    auth
        .signInWithCredential(credential)
        .then(authListener.onSignedIn)
        .catchError(authListener.onError);
  }

  /// Links a provided [AuthCredential] with the currently signed in user
  /// account.
  void linkWithCredential(K credential) {
    authListener.onCredentialReceived(credential);

    try {
      final user = auth.currentUser!;
      user
          .linkWithCredential(credential)
          .then((_) => authListener.onCredentialLinked(credential))
          .catchError(authListener.onError);
    } catch (err) {
      authListener.onError(err);
    }
  }

  /// Fetches available providers for the given [email].
  void findProvidersForEmail(
    String email, [
    AuthCredential? credential,
  ]) {
    authListener.onBeforeProvidersForEmailFetch();

    auth
        .fetchSignInMethodsForEmail(email)
        .then(
          (methods) => authListener.onDifferentProvidersFound(
            email,
            methods,
            credential,
          ),
        )
        .catchError(authListener.onError);
  }

  /// {@template ui.auth.auth_provider.on_credential_received}
  /// A method that is called when the user has successfully completed the
  /// authentication process and decides what to do with the obtained
  /// [credential].
  ///
  /// [linkWithCredential] and respectful lifecycle hooks are called if [action]
  /// is [AuthAction.link].
  ///
  /// [signInWithCredential] and respectful lifecycle hooks are called
  /// if [action] is [AuthAction.signIn].
  ///
  /// [FirebaseAuth.createUserWithEmailAndPassword] and respectful lifecycle
  /// hooks are called if action is [AuthAction.signUp].
  /// {@endtemplate}
  void onCredentialReceived(K credential, AuthAction action) {
    switch (action) {
      case AuthAction.link:
        linkWithCredential(credential);
        break;
      case AuthAction.signIn:
      // Only email provider has a different action for sign in and sign up
      // and implements it's own sign up logic.
      case AuthAction.signUp:
        if (shouldUpgradeAnonymous) {
          linkWithCredential(credential);
          break;
        }

        signInWithCredential(credential);
        break;
      case AuthAction.none:
        authListener.onCredentialReceived(credential);
        break;
    }
  }
}
