// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart' hide OAuthProvider;
import '../oauth/oauth_providers.dart';
import 'package:flutter/foundation.dart' show TargetPlatform, kIsWeb;

import '../auth_controller.dart';
import '../auth_flow.dart';
import '../auth_state.dart';
import '../configs/oauth_provider_configuration.dart';

abstract class OAuthController extends AuthController {
  Future<void> signInWithProvider(TargetPlatform platform);
}

class OAuthFlow extends AuthFlow implements OAuthController {
  OAuthFlow({
    required this.config,
    AuthAction? action,
    FirebaseAuth? auth,
  }) : super(action: action, auth: auth, initialState: const Uninitialized());

  final OAuthProviderConfiguration config;

  @override
  Future<void> signInWithProvider(TargetPlatform platform) async {
    OAuthProvider? provider = OAuthProviders.resolve(auth, config.providerType);

    if (provider == null) {
      provider = config.createProvider();
      OAuthProviders.register(auth, provider);
    }

    try {
      value = const SigningIn();

      late OAuthCredential credential;

      if (kIsWeb) {
        return await _signInWeb(provider);
      } else if (platform == TargetPlatform.macOS) {
        credential = await provider.desktopSignIn();
      } else {
        credential = await provider.signIn();
      }

      setCredential(credential);
    } on Exception catch (e) {
      value = AuthFailed(e);
    }
  }

  Future<void> _signInWeb(OAuthProvider provider) async {
    try {
      final userCredential = await auth.signInWithPopup(
        provider.firebaseAuthProvider,
      );

      value = SignedIn(userCredential.user);
    } on FirebaseAuthException catch (err) {
      handleError(err);
    }
  }
}
