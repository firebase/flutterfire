import 'package:firebase_auth/firebase_auth.dart' hide OAuthProvider;
import 'package:flutterfire_ui/i10n.dart';
import 'package:flutter/foundation.dart';
// import 'package:flutterfire_ui/auth/google.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:desktop_webview_auth/desktop_webview_auth.dart';
import 'package:desktop_webview_auth/google.dart';

import 'package:flutterfire_ui/auth.dart';

import '../../auth_flow.dart';
import '../../widgets/internal/oauth_provider_button_style.dart';
import '../oauth_providers.dart';
import '../provider_resolvers.dart';

class GoogleProviderImpl extends OAuthProvider {
  String clientId;
  String redirectUri;

  final _provider = GoogleSignIn();

  @override
  late final desktopSignInArgs = GoogleSignInArgs(
    clientId: clientId,
    redirectUri: redirectUri,
  );

  GoogleProviderImpl({
    required this.clientId,
    required this.redirectUri,
  });

  @override
  Future<OAuthCredential> signIn() async {
    final user = await _provider.signIn();

    if (user == null) {
      throw AuthCancelledException();
    }

    final auth = await user.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: auth.accessToken,
      idToken: auth.idToken,
    );

    return credential;
  }

  @override
  OAuthCredential fromDesktopAuthResult(AuthResult result) {
    return GoogleAuthProvider.credential(accessToken: result.accessToken);
  }

  @override
  GoogleAuthProvider get firebaseAuthProvider => GoogleAuthProvider();
}

class GoogleProviderConfiguration extends OAuthProviderConfiguration {
  final String clientId;
  final String? redirectUri;

  GoogleProviderImpl get _provider => GoogleProviderImpl(
        clientId: clientId,
        redirectUri: redirectUri ?? defaultRedirectUri,
      );

  const GoogleProviderConfiguration({
    required this.clientId,
    this.redirectUri,
  });

  @override
  String get providerId => GOOGLE_PROVIDER_ID;

  @override
  OAuthProvider createProvider() {
    return _provider;
  }

  @override
  String getLabel(FlutterFireUILocalizationLabels labels) {
    return labels.signInWithGoogleButtonText;
  }

  @override
  ThemedOAuthProviderButtonStyle get style => GoogleProviderButtonStyle();

  @override
  bool isSupportedPlatform(TargetPlatform platform) {
    return platform == TargetPlatform.android ||
        platform == TargetPlatform.iOS ||
        platform == TargetPlatform.macOS ||
        kIsWeb;
  }
}
