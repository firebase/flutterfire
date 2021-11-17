import 'package:firebase_auth/firebase_auth.dart' hide OAuthProvider;
import 'package:firebase_ui/i10n.dart';
// import 'package:firebase_ui/auth/google.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:desktop_webview_auth/desktop_webview_auth.dart';
import 'package:desktop_webview_auth/google.dart';

import 'package:firebase_ui/auth.dart';

import '../../auth_flow.dart';
import '../../configs/oauth_provider_configuration.dart';
import '../../widgets/internal/oauth_provider_button_style.dart';
import '../../widgets/google_sign_in_button.dart';
import '../oauth_providers.dart';
import '../provider_resolvers.dart';

class GoogleProviderImpl extends Google {
  String? clientId;
  String redirectUri;

  final _provider = GoogleSignIn();

  @override
  late final desktopSignInArgs = GoogleSignInArgs(
    clientId: clientId!,
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
}

class GoogleProviderConfiguration extends OAuthProviderConfiguration {
  final String? clientId;
  final String? redirectUri;

  GoogleProviderImpl get _provider => GoogleProviderImpl(
        clientId: clientId,
        redirectUri: redirectUri ?? defaultRedirectUri,
      );

  const GoogleProviderConfiguration({
    this.clientId,
    this.redirectUri,
  });

  @override
  String get providerId => GOOGLE_PROVIDER_ID;

  @override
  OAuthProvider createProvider() {
    return _provider;
  }

  @override
  String getLabel(FirebaseUILocalizationLabels labels) {
    return labels.signInWithGoogleButtonText;
  }

  @override
  ThemedOAuthProviderButtonStyle get style => GoogleProviderButtonStyle();
}
