// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart' hide OAuthProvider;
import 'package:flutter/foundation.dart';
import 'package:firebase_ui_oauth/firebase_ui_oauth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleProvider extends OAuthProvider {
  @override
  final providerId = 'google.com';

  /// The Google client ID.
  /// Primarily required for desktop platforms.
  /// Ignored on Android and iOS (if `iOSPreferPlist` is true).
  final String clientId;

  /// When true, the Google Sign In plugin will use the GoogleService-Info.plist
  /// for configuration instead of the `clientId` parameter.
  final bool iOSPreferPlist;

  /// The redirect URL to use for the Google Sign In plugin.
  /// Required on desktop platforms.
  final String? redirectUri;

  /// The list of requested authroization scopes requested when signing in.
  final List<String>? scopes;

  late GoogleSignIn provider;

  @override
  final GoogleAuthProvider firebaseAuthProvider = GoogleAuthProvider();

  @override
  late final desktopSignInArgs = GoogleSignInArgs(
    clientId: clientId,
    redirectUri: redirectUri ?? defaultRedirectUri,
    scope: scopes != null
        ? scopes!.join(' ')
        : 'https://www.googleapis.com/auth/plus.login',
  );

  GoogleProvider({
    required this.clientId,
    this.redirectUri,
    this.scopes,
    this.iOSPreferPlist = false,
  }) {
    firebaseAuthProvider.setCustomParameters(const {
      'prompt': 'select_account',
    });

    if (_ignoreClientId()) {
      provider = GoogleSignIn(scopes: scopes ?? []);
    } else {
      provider = GoogleSignIn(
        clientId: clientId,
        scopes: scopes ?? [],
      );
    }
  }

  bool _ignoreClientId() {
    if (defaultTargetPlatform == TargetPlatform.android) return true;
    if (defaultTargetPlatform == TargetPlatform.iOS && iOSPreferPlist) {
      return true;
    }

    return false;
  }

  @override
  void mobileSignIn(AuthAction action) async {
    provider.signIn().then((user) {
      if (user == null) throw AuthCancelledException();
      return user.authentication;
    }).then((auth) {
      final credential = GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );

      onCredentialReceived(credential, action);
    }).catchError((err) {
      authListener.onError(err);
    });
  }

  @override
  OAuthCredential fromDesktopAuthResult(AuthResult result) {
    return GoogleAuthProvider.credential(
      idToken: result.idToken,
      accessToken: result.accessToken,
    );
  }

  @override
  Future<void> logOutProvider() async {
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      await provider.signOut();
    }
  }

  @override
  final style = const GoogleProviderButtonStyle();

  @override
  bool supportsPlatform(TargetPlatform platform) {
    return true;
  }
}
