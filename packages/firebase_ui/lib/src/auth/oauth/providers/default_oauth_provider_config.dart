import 'package:firebase_ui/auth/apple.dart';
import 'package:firebase_ui/auth/facebook.dart';
import 'package:firebase_ui/auth/google.dart';
import 'package:firebase_ui/src/auth/oauth/oauth_provider_configuration.dart';
import 'package:firebase_ui/src/auth/oauth/oauth_providers.dart';

OAuthProviderConfiguration
    createDefaultOAuthProviderConfiguration<T extends OAuthProvider>() {
  switch (T) {
    case Google:
      return GoogleProviderConfiguration();

    case Facebook:
      return FacebookProviderConfiguration();

    case Apple:
      return AppleProviderConfiguration();

    default:
      throw Exception("Can't create default provider configuration for $T");
  }
}
