import 'package:firebase_auth/firebase_auth.dart' hide OAuthProvider;
import 'package:firebase_ui/src/auth/oauth/oauth_providers.dart';
import 'package:flutter/foundation.dart' show TargetPlatform;

import '../auth_controller.dart';
import '../auth_flow.dart';
import '../auth_state.dart';
import '../configs/oauth_provider_configuration.dart';

class Uninitialized extends AuthState {
  const Uninitialized();
}

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
    final provider = config.createProvider();

    try {
      value = const SigningIn();

      late OAuthCredential credential;

      if (platform == TargetPlatform.macOS) {
        credential = await provider.desktopSignIn();
      } else {
        credential = await provider.signIn();
      }

      setCredential(credential);
    } on Exception catch (e) {
      value = AuthFailed(e);
    }
  }
}
