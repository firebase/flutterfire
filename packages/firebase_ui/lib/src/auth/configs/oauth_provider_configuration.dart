import 'package:firebase_core/firebase_core.dart';

import 'package:firebase_ui/src/auth/auth_flow.dart';
import 'package:firebase_ui/src/auth/auth_controller.dart';
import 'package:firebase_auth/firebase_auth.dart' hide OAuthProvider;
import 'package:firebase_ui/src/auth/oauth/oauth_providers.dart';
import 'package:firebase_ui/src/auth/provider_configuration.dart';

import '../flows/oauth_flow.dart';

abstract class OAuthProviderConfiguration extends ProviderConfiguration {
  final defaultRedirectUri =
      '${Firebase.apps.first.name}.firebaseapp.com/__/auth/handler';

  @override
  AuthFlow createFlow(FirebaseAuth? auth, AuthAction? action) {
    return OAuthFlow(
      auth: auth,
      action: action,
      config: this,
    );
  }

  OAuthProvider createProvider();
}
