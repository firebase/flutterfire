import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' hide OAuthProvider;
import 'package:firebase_ui/src/auth/oauth/oauth_provider_configuration.dart';
import 'package:firebase_ui/src/auth/oauth/provider_resolvers.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart' show launch;
import 'package:deep_links/deep_links.dart';

import '../oauth_providers.dart';
import 'package:flutter/services.dart';

class GoogleSignInDesktop {
  static const _methodChannel = MethodChannel('google_sign_in_desktop');

  static GoogleSignInDesktop? _instance;
  static GoogleSignInDesktop get instance =>
      _instance ?? GoogleSignInDesktop._();

  GoogleSignInDesktop._();

  Future<OAuthCredential> signIn(String clientId, String redirectUri) async {
    final callbackUrl = await _methodChannel.invokeMethod<String>('signIn', {
      'clientId': clientId,
      'redirectUri': redirectUri,
    });

    final uri = Uri.parse(callbackUrl!.replaceFirst('#', '?'));

    final credential = GoogleAuthProvider.credential(
      accessToken: uri.queryParameters['access_token'],
    );

    return credential;
  }
}

class GoogleProviderImpl extends Google {
  final String clientId;
  final String redirectUri;

  final _provider = GoogleSignIn();

  GoogleProviderImpl({required this.clientId, required this.redirectUri});

  @override
  Future<OAuthCredential> signIn() async {
    if (Platform.isMacOS) {
      return _signInMacOSWebViewFlow();
    }

    final user = await _provider.signIn();
    final auth = await user!.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: auth.accessToken,
      idToken: auth.idToken,
    );

    return credential;
  }

  Future<OAuthCredential> _signInMacOSWebViewFlow() async {
    return GoogleSignInDesktop.instance.signIn(clientId, redirectUri);
  }

  Future<OAuthCredential> _signInMacOSBrowserFlow() async {
    await launch('http://localhost:5000/google_sign_in.html');
    final dl = DeepLinks();
    final link = await dl.onLinkReceived.first;
    final uri = Uri.parse(link);
    final accessToken = uri.queryParameters['accessToken'];
    final idToken = uri.queryParameters['idToken'];

    final credential = GoogleAuthProvider.credential(
      accessToken: accessToken,
      idToken: idToken,
    );

    return credential;
  }
}

class GoogleProviderConfiguration extends OAuthProviderConfiguration {
  final String clientId;
  final String redirectUri;

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
