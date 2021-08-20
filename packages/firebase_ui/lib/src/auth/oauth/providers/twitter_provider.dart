import 'package:firebase_auth/firebase_auth.dart' hide OAuthProvider;
import 'package:firebase_ui/src/auth/oauth/oauth_provider_configuration.dart';
import 'package:firebase_ui/src/auth/oauth/provider_resolvers.dart';

import 'package:twitter_login/twitter_login.dart';

import '../oauth_providers.dart';

class TwitterProviderImpl extends Twitter {
  final String apiKey;
  final String apiSecretKey;
  final String redirectURI;

  late final _provider = TwitterLogin(
    apiKey: apiKey,
    apiSecretKey: apiSecretKey,
    redirectURI: redirectURI,
  );

  TwitterProviderImpl({
    required this.apiKey,
    required this.apiSecretKey,
    required this.redirectURI,
  });

  @override
  Future<OAuthCredential> signIn() async {
    final result = await _provider.login();

    return TwitterAuthProvider.credential(
      accessToken: result.authToken!,
      secret: result.authTokenSecret!,
    );
  }
}

class TwitterProviderConfiguration extends OAuthProviderConfiguration {
  final String apiKey;
  final String apiSecretKey;
  final String redirectURI;

  late final _provider = TwitterProviderImpl(
    apiKey: apiKey,
    apiSecretKey: apiSecretKey,
    redirectURI: redirectURI,
  );

  TwitterProviderConfiguration({
    required this.apiKey,
    required this.apiSecretKey,
    required this.redirectURI,
  });

  @override
  String get providerId => TWITTER_PROVIDER_ID;

  @override
  OAuthProvider createProvider() {
    return _provider;
  }
}
