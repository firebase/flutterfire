import 'package:firebase_ui/src/auth/auth_flow.dart';
import 'package:firebase_ui/src/auth/auth_controller.dart';
import 'package:firebase_auth/firebase_auth.dart' hide OAuthProvider;
import 'package:firebase_ui/src/auth/oauth/oauth_providers.dart';
import 'package:firebase_ui/src/auth/provider_configuration.dart';

import 'oauth_flow.dart';

abstract class OAuthProviderConfiguration extends ProviderConfiguration {
  @override
  Type get controllerType => OAuthController;

  @override
  AuthFlow createFlow(FirebaseAuth auth, AuthMethod method) {
    return OAuthFlow(auth: auth, method: method);
  }

  OAuthProvider createProvider();
}
