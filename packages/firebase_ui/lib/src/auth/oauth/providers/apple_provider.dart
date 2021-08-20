import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:firebase_ui/src/auth/oauth/oauth_provider_configuration.dart';
import 'package:firebase_ui/src/auth/oauth/oauth_providers.dart';
import 'package:firebase_ui/src/auth/oauth/provider_resolvers.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../oauth_providers.dart' show Apple;

/// Generates a cryptographically secure random nonce, to be included in a
/// credential request.
String generateNonce([int length = 32]) {
  const charset =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
  final random = Random.secure();
  return List.generate(length, (_) => charset[random.nextInt(charset.length)])
      .join();
}

/// Returns the sha256 hash of [input] in hex notation.
String sha256ofString(String input) {
  final bytes = utf8.encode(input);
  final digest = sha256.convert(bytes);
  return digest.toString();
}

class AppleProviderImpl extends Apple {
  final WebAuthenticationOptions? options;

  AppleProviderImpl(this.options);

  @override
  Future<fba.OAuthCredential> signIn() async {
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    // Request credential for the currently signed in Apple account.
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    // Create an `OAuthCredential` from the credential returned by Apple.
    final oauthCredential = fba.OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );

    return oauthCredential;
  }
}

class AppleProviderConfiguration extends OAuthProviderConfiguration {
  final WebAuthenticationOptions? options;

  AppleProviderConfiguration({this.options});

  @override
  OAuthProvider createProvider() {
    return AppleProviderImpl(options);
  }

  @override
  String get providerId => APPLE_PROVIDER_ID;
}
