import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:desktop_webview_auth/desktop_webview_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:flutterfire_ui/i10n.dart';
import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../widgets/apple_sign_in_button.dart' show AppleProviderButtonStyle;
import '../../configs/oauth_provider_configuration.dart';
import '../../oauth/oauth_providers.dart';
import '../../oauth/provider_resolvers.dart';
import '../../widgets/internal/oauth_provider_button_style.dart';

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

abstract class AppleProvider extends OAuthProvider {}

class AppleProviderImpl extends AppleProvider {
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

  @override
  Future<fba.OAuthCredential> desktopSignIn() {
    return signIn();
  }

  @override
  ProviderArgs get desktopSignInArgs => throw UnimplementedError();

  @override
  fba.OAuthCredential fromDesktopAuthResult(AuthResult result) {
    throw UnimplementedError();
  }

  @override
  dynamic get firebaseAuthProvider => null;

  @override
  Future<void> logOutProvider() {
    return SynchronousFuture(null);
  }
}

class AppleProviderConfiguration
    extends OAuthProviderConfiguration<AppleProvider> {
  const AppleProviderConfiguration();

  @override
  AppleProvider createProvider() {
    return AppleProviderImpl();
  }

  @override
  String get providerId => APPLE_PROVIDER_ID;

  @override
  ThemedOAuthProviderButtonStyle get style => const AppleProviderButtonStyle();

  @override
  String getLabel(FlutterFireUILocalizationLabels labels) {
    return labels.signInWithAppleButtonText;
  }

  @override
  bool isSupportedPlatform(TargetPlatform platform) {
    return !kIsWeb &&
        (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS);
  }
}
