// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

/// A listener of the [EmailLinkFlow] lifecycle.
abstract class EmailLinkAuthListener extends AuthListener {
  /// Called when the link being is sent to the user's [email].
  void onBeforeLinkSent(String email);

  /// Called when the link was sucessfully sent to the [email].
  void onLinkSent(String email);
}

/// {@template ui.auth.providers.email_link_auth_provider}
/// An [AuthProvider] that allows to authenticate using a link that is being
/// sent to the user's email.
/// {@endtemplate}
class EmailLinkAuthProvider
    extends AuthProvider<EmailLinkAuthListener, AuthCredential> {
  /// A configuration of the dynamic link.
  final ActionCodeSettings actionCodeSettings;
  final FirebaseDynamicLinks _dynamicLinks;

  @override
  late EmailLinkAuthListener authListener;

  @override
  final providerId = 'email_link';

  @override
  bool supportsPlatform(TargetPlatform platform) {
    if (kIsWeb) return false;
    return platform == TargetPlatform.android || platform == TargetPlatform.iOS;
  }

  /// {@macro ui.auth.providers.email_link_auth_provider}
  EmailLinkAuthProvider({
    required this.actionCodeSettings,

    /// An instance of the [FirebaseDynamicLinks] that should be used to handle
    /// the link. By default [FirebaseDynamicLinks.instance] is used.
    FirebaseDynamicLinks? dynamicLinks,
  }) : _dynamicLinks = dynamicLinks ?? FirebaseDynamicLinks.instance;

  /// Sends a link to the [email].
  void sendLink(String email) {
    authListener.onBeforeLinkSent(email);

    final future = auth.sendSignInLinkToEmail(
      email: email,
      actionCodeSettings: actionCodeSettings,
    );

    future
        .then((_) => authListener.onLinkSent(email))
        .catchError(authListener.onError);
  }

  void _onLinkReceived(String email, PendingDynamicLinkData linkData) {
    final link = linkData.link.toString();

    if (auth.isSignInWithEmailLink(link)) {
      authListener.onBeforeSignIn();
      _signInWithEmailLink(email, link);
    } else {
      authListener.onError(
        FirebaseAuthException(
          code: 'invalid-email-signin-link',
          message: 'Invalid email sign in link',
        ),
      );
    }
  }

  /// Calls [FirebaseDynamicLinks] to receive the link and perform a sign in.
  /// Should be called after [EmailLinkAuthListener.onLinkSent] was called.
  void awaitLink(String email) {
    _dynamicLinks.onLink.first
        .then((linkData) => _onLinkReceived(email, linkData))
        .catchError(authListener.onError);
  }

  void _signInWithEmailLink(String email, String link) {
    auth
        .signInWithEmailLink(email: email, emailLink: link)
        .then(authListener.onSignedIn)
        .catchError(authListener.onError);
  }
}
