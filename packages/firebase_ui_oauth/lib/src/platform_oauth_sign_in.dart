// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:desktop_webview_auth/desktop_webview_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

import 'oauth_provider.dart';

/// {@template ui.oauth.platform_sign_in_mixin}
/// A helper mixin that implements the platform-specific sign-in logic.
/// {@endtemplate}
mixin PlatformSignInMixin {
  OAuthListener get authListener;
  ProviderArgs get desktopSignInArgs;
  dynamic get firebaseAuthProvider;

  /// Creates [OAuthCredential] based on [AuthResult].
  OAuthCredential fromDesktopAuthResult(AuthResult result);

  /// {@macro ui.auth.auth_provider.on_credential_received}
  void onCredentialReceived(OAuthCredential credential, AuthAction action);

  /// {@template ui.oauth.platform_sign_in_mixin.platform_sign_in}
  /// Redirects the flow to the [mobileSignIn] or [desktopSignIn] based
  /// on current platform.
  /// {@endtemplate}
  void platformSignIn(TargetPlatform platform, AuthAction action) {
    if (platform == TargetPlatform.android || platform == TargetPlatform.iOS) {
      mobileSignIn(action);
    } else {
      desktopSignIn(action);
    }
  }

  /// Handles authentication logic on desktop platforms
  void desktopSignIn(AuthAction action) {
    DesktopWebviewAuth.signIn(desktopSignInArgs).then((value) {
      if (value == null) throw AuthCancelledException();

      final oauthCredential = fromDesktopAuthResult(value);
      onCredentialReceived(oauthCredential, action);
    }).catchError((err) {
      if (err is AuthCancelledException) {
        authListener.onCanceled();
        return;
      }

      authListener.onError(err);
    });
  }

  /// Handles authentication logic on mobile platforms.
  void mobileSignIn(AuthAction action);
}
