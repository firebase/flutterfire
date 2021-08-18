import 'package:firebase_auth/firebase_auth.dart' hide OAuthProvider;
import 'package:firebase_ui/src/auth/oauth/oauth_provider_configuration.dart';
import 'package:firebase_ui/src/auth/oauth/provider_resolvers.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../oauth_providers.dart';

class GoogleProviderImpl extends Google {
  final _provider = GoogleSignIn();

  @override
  Future<OAuthCredential> signIn() async {
    final user = await _provider.signIn();
    final auth = await user!.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: auth.accessToken,
      idToken: auth.idToken,
    );

    return credential;
  }
}

class GoogleProviderConfiguration extends OAuthProviderConfiguration {
  final _provider = GoogleProviderImpl();

  @override
  String get providerId => GOOGLE_PROVIDER_ID;

  @override
  OAuthProvider createProvider() {
    return _provider;
  }
}
