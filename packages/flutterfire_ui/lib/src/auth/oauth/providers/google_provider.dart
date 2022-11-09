// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart' hide OAuthProvider;
import 'package:flutterfire_ui/i10n.dart';
import 'package:flutter/foundation.dart';
// import 'package:flutterfire_ui/auth/google.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:desktop_webview_auth/desktop_webview_auth.dart';
import 'package:desktop_webview_auth/google.dart';

import 'package:flutterfire_ui/auth.dart';

import '../../auth_flow.dart';
import '../../widgets/internal/oauth_provider_button_style.dart';
import '../oauth_providers.dart';
import '../provider_resolvers.dart';

import 'sign_out_mixin.dart' if (dart.library.html) 'sign_out_mixin_web.dart';

const _firebaseAuthProviderParameters = {
  'prompt': 'select_account',
};

abstract class GoogleProvider extends OAuthProvider {}

class GoogleProviderImpl extends GoogleProvider with SignOutMixin {
  String clientId;
  String redirectUri;
  List<String> scopes;

  late final provider = GoogleSignIn(
    clientId: clientId,
    scopes: scopes,
  );

  @override
  final GoogleAuthProvider firebaseAuthProvider = GoogleAuthProvider();

  @override
  late final desktopSignInArgs = GoogleSignInArgs(
    clientId: clientId,
    redirectUri: redirectUri,
    scope: scopes.join(' '),
  );

  GoogleProviderImpl({
    required this.clientId,
    required this.redirectUri,
    this.scopes = const [],
  }) {
    firebaseAuthProvider.setCustomParameters(_firebaseAuthProviderParameters);
  }

  @override
  Future<OAuthCredential> signIn() async {
    final user = await provider.signIn();

    if (user == null) {
      throw AuthCancelledException();
    }

    final auth = await user.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: auth.accessToken,
      idToken: auth.idToken,
    );

    return credential;
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
    await provider.signOut();
  }
}

class GoogleProviderConfiguration
    extends OAuthProviderConfiguration<GoogleProvider> {
  final String clientId;
  final String? redirectUri;
  final List<String> scopes;

  GoogleProviderImpl get _provider => GoogleProviderImpl(
        clientId: clientId,
        redirectUri: redirectUri ?? defaultRedirectUri,
        scopes: scopes,
      );

  const GoogleProviderConfiguration({
    required this.clientId,
    this.redirectUri,
    this.scopes = const [],
  });

  @override
  String get providerId => GOOGLE_PROVIDER_ID;

  @override
  GoogleProvider createProvider() {
    return _provider;
  }

  @override
  String getLabel(FlutterFireUILocalizationLabels labels) {
    return labels.signInWithGoogleButtonText;
  }

  @override
  ThemedOAuthProviderButtonStyle get style => GoogleProviderButtonStyle();

  @override
  bool isSupportedPlatform(TargetPlatform platform) {
    return platform == TargetPlatform.android ||
        platform == TargetPlatform.iOS ||
        platform == TargetPlatform.macOS ||
        kIsWeb;
  }
}
