// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

import 'oauth_provider.dart';

/// {@macro ui.oauth.platform_sign_in_mixin}
mixin PlatformSignInMixin {
  FirebaseAuth get auth;
  OAuthListener get authListener;
  dynamic get firebaseAuthProvider;

  /// {@macro ui.oauth.platform_sign_in_mixin.platform_sign_in}
  void platformSignIn(TargetPlatform platform, AuthAction action) {
    Future<UserCredential> credentialFuture;

    if (action == AuthAction.link) {
      credentialFuture = auth.currentUser!.linkWithPopup(firebaseAuthProvider);
    } else {
      credentialFuture = auth.signInWithPopup(firebaseAuthProvider);
    }

    credentialFuture
        .then(authListener.onSignedIn)
        .catchError(authListener.onError);
  }
}
