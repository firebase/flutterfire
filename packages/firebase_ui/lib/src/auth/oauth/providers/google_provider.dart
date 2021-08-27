import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' hide OAuthProvider;
import 'package:firebase_ui/src/auth/oauth/oauth_provider_configuration.dart';
import 'package:firebase_ui/src/auth/oauth/provider_resolvers.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart' show launch;
import 'package:deep_links/deep_links.dart';

import '../oauth_providers.dart';

class GoogleProviderImpl extends Google {
  final _provider = GoogleSignIn();

  @override
  Future<OAuthCredential> signIn() async {
    if (Platform.isMacOS) {
      return _signInMacOS();
    }

    final user = await _provider.signIn();
    final auth = await user!.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: auth.accessToken,
      idToken: auth.idToken,
    );

    return credential;
  }

  Future<OAuthCredential> _signInMacOS() async {
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
  final _provider = GoogleProviderImpl();

  @override
  String get providerId => GOOGLE_PROVIDER_ID;

  @override
  OAuthProvider createProvider() {
    return _provider;
  }
}
