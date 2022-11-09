// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:desktop_webview_auth/desktop_webview_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' hide OAuthProvider;
import 'package:desktop_webview_auth/twitter.dart';
import 'package:flutterfire_ui/i10n.dart';
import 'package:flutter/foundation.dart';
import 'package:twitter_login/twitter_login.dart';

import 'package:flutterfire_ui/auth.dart';
import '../provider_resolvers.dart';
import '../../widgets/internal/oauth_provider_button_style.dart';

import '../../auth_flow.dart';
import '../oauth_providers.dart';

import 'sign_out_mixin.dart' if (dart.library.html) 'sign_out_mixin_web.dart';

abstract class TwitterProvider extends OAuthProvider {}

class TwitterProviderImpl extends TwitterProvider with SignOutMixin {
  final String apiKey;
  final String apiSecretKey;
  final String redirectUri;

  @override
  late final desktopSignInArgs = TwitterSignInArgs(
    apiKey: apiKey,
    apiSecretKey: apiSecretKey,
    redirectUri: redirectUri,
  );

  late final provider = TwitterLogin(
    apiKey: apiKey,
    apiSecretKey: apiSecretKey,
    redirectURI: redirectUri,
  );

  TwitterProviderImpl({
    required this.apiKey,
    required this.apiSecretKey,
    required this.redirectUri,
  });

  @override
  Future<OAuthCredential> signIn() async {
    final result = await provider.login();

    switch (result.status) {
      case null:
        throw Exception('Unknown sign in result');
      case TwitterLoginStatus.loggedIn:
        return TwitterAuthProvider.credential(
          accessToken: result.authToken!,
          secret: result.authTokenSecret!,
        );
      case TwitterLoginStatus.cancelledByUser:
        throw AuthCancelledException();
      case TwitterLoginStatus.error:
        throw Exception(result.errorMessage);
    }
  }

  @override
  OAuthCredential fromDesktopAuthResult(AuthResult result) {
    return TwitterAuthProvider.credential(
      accessToken: result.accessToken!,
      secret: result.tokenSecret!,
    );
  }

  @override
  TwitterAuthProvider get firebaseAuthProvider => TwitterAuthProvider();

  @override
  Future<void> logOutProvider() {
    return SynchronousFuture(null);
  }
}

class TwitterProviderConfiguration
    extends OAuthProviderConfiguration<TwitterProvider> {
  final String apiKey;
  final String apiSecretKey;
  final String redirectUri;

  TwitterProvider get _provider => TwitterProviderImpl(
        apiKey: apiKey,
        apiSecretKey: apiSecretKey,
        redirectUri: redirectUri,
      );

  const TwitterProviderConfiguration({
    required this.apiKey,
    required this.apiSecretKey,
    required this.redirectUri,
  });

  @override
  String get providerId => TWITTER_PROVIDER_ID;

  @override
  TwitterProvider createProvider() {
    return _provider;
  }

  @override
  String getLabel(FlutterFireUILocalizationLabels labels) {
    return labels.signInWithTwitterButtonText;
  }

  @override
  ThemedOAuthProviderButtonStyle get style =>
      const TwitterProviderButtonStyle();

  @override
  bool isSupportedPlatform(TargetPlatform platform) {
    return platform == TargetPlatform.android ||
        platform == TargetPlatform.iOS ||
        platform == TargetPlatform.macOS;
  }
}
