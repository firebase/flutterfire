import 'package:firebase_auth/firebase_auth.dart' hide OAuthProvider;
import 'package:firebase_ui/src/auth/oauth/oauth_provider_configuration.dart';
import 'package:firebase_ui/src/auth/oauth/provider_resolvers.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import '../oauth_providers.dart';

class FacebookProviderImpl extends Facebook {
  final _provider = FacebookAuth.instance;

  @override
  Future<OAuthCredential> signIn() async {
    final user = await _provider.login();
    final credential = FacebookAuthProvider.credential(user.accessToken!.token);

    return credential;
  }
}

class FacebookProviderConfiguration extends OAuthProviderConfiguration {
  final _provider = FacebookProviderImpl();

  @override
  String get providerId => FACEBOOK_PROVIDER_ID;

  @override
  OAuthProvider createProvider() {
    return _provider;
  }
}
