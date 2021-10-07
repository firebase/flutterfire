import 'dart:io';

import 'package:desktop_webview_auth/google.dart';
import 'package:firebase_auth/firebase_auth.dart' hide OAuthProvider;
import 'package:desktop_webview_auth/desktop_webview_auth.dart';

import 'package:firebase_ui/src/auth/oauth/oauth_provider_configuration.dart';
import 'package:firebase_ui/src/auth/oauth/provider_resolvers.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../oauth_providers.dart';

class GoogleProviderImpl extends Google {
  String? clientId;
  String? redirectUri;

  final _provider = GoogleSignIn();

  GoogleProviderImpl({required this.clientId, required this.redirectUri});

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

  @override
  ProviderArgs get desktopSignInArgs {
    if (clientId == null || redirectUri == null) {
      throw MissingDesktopArgException(['clientId', 'redirectUri']);
    }

    return GoogleSignInArgs(clientId: clientId!, redirectUri: redirectUri!);
  }

  @override
  OAuthCredential fromDesktopAuthResult(AuthResult result) {
    return GoogleAuthProvider.credential(accessToken: result.accessToken);
  }
}

class GoogleProviderConfiguration extends OAuthProviderConfiguration {
  String? clientId;
  String? redirectUri;

  late final _provider = GoogleProviderImpl(
    clientId: clientId,
    redirectUri: redirectUri,
  );

  GoogleProviderConfiguration({
    required this.clientId,
    required this.redirectUri,
  });

  @override
  String get providerId => GOOGLE_PROVIDER_ID;

  @override
  OAuthProvider createProvider() {
    return _provider;
  }
}
