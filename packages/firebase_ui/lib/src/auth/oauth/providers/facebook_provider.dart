import 'package:firebase_auth/firebase_auth.dart' hide OAuthProvider;
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import 'package:desktop_webview_auth/desktop_webview_auth.dart';
import 'package:desktop_webview_auth/facebook.dart';
import 'package:firebase_ui/auth.dart';
import 'package:firebase_ui/src/auth/configs/oauth_provider_configuration.dart';
import 'package:firebase_ui/src/auth/oauth/provider_resolvers.dart';

import '../../auth_flow.dart';
import '../oauth_providers.dart';

class FacebookProviderImpl extends Facebook {
  final _provider = FacebookAuth.instance;
  final String clientId;
  final String redirectUri;

  @override
  late final ProviderArgs desktopSignInArgs = FacebookSignInArgs(
    clientId: clientId,
    redirectUri: redirectUri,
  );

  FacebookProviderImpl({
    required this.clientId,
    required this.redirectUri,
  });

  @override
  Future<OAuthCredential> signIn() async {
    final result = await _provider.login();

    switch (result.status) {
      case LoginStatus.success:
        final credential =
            FacebookAuthProvider.credential(result.accessToken!.token);

        return credential;
      case LoginStatus.cancelled:
        throw AuthCancelledException();
      case LoginStatus.failed:
        throw Exception(result.message);
      case LoginStatus.operationInProgress:
        throw Exception('Previous login request is not complete');
    }
  }

  @override
  OAuthCredential fromDesktopAuthResult(AuthResult result) {
    return FacebookAuthProvider.credential(result.accessToken);
  }
}

class FacebookProviderConfiguration extends OAuthProviderConfiguration {
  final String clientId;
  final String? redirectUri;

  FacebookProviderConfiguration({
    required this.clientId,
    this.redirectUri,
  });

  late final _provider = FacebookProviderImpl(
    clientId: clientId,
    redirectUri: redirectUri ?? defaultRedirectUri,
  );

  @override
  String get providerId => FACEBOOK_PROVIDER_ID;

  @override
  OAuthProvider createProvider() {
    return _provider;
  }
}
