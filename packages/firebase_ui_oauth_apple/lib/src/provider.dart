import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:flutter/foundation.dart';
import 'package:firebase_ui_oauth/firebase_ui_oauth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'theme.dart';

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

class AppleProviderBackend {
  OAuthCredential _createOAuthCredential(
    AuthorizationCredentialAppleID credential,
    String rawNonce,
  ) {
    return fba.OAuthProvider('apple.com').credential(
      idToken: credential.identityToken,
      rawNonce: rawNonce,
    );
  }

  Future<OAuthCredential> signIn() {
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    // Request credential for the currently signed in Apple account.
    final appleCredentialFuture = SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    return appleCredentialFuture.then((credential) {
      return _createOAuthCredential(credential, rawNonce);
    });
  }
}

class AppleProvider extends OAuthProvider {
  @override
  final providerId = 'apple.com';

  @override
  final style = const AppleProviderButtonStyle();

  AppleProviderBackend provider = AppleProviderBackend();

  @override
  void mobileSignIn(AuthAction action) {
    provider.signIn().then((credential) {
      onCredentialReceived(credential, action);
    }).catchError((err) {
      if (err is SignInWithAppleAuthorizationException) {
        switch (err.code) {
          case AuthorizationErrorCode.canceled:
            authListener.onCanceled();
            return;
          default:
            authListener.onError(err);
        }
      }
      authListener.onError(err);
    });
  }

  @override
  void desktopSignIn(AuthAction action) {
    mobileSignIn(action);
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

  @override
  bool supportsPlatform(TargetPlatform platform) {
    return !kIsWeb &&
        (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS);
  }
}
