import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;

import 'package:firebase_ui/src/auth/oauth/buttons/oauth_provider_button.dart';
import 'package:firebase_ui/src/auth/oauth/providers/google_provider.dart';

import '../auth.dart';

export '../src/auth/oauth/providers/google_provider.dart'
    show GoogleProviderConfiguration;

class _GoogleSignInButtonContainer
    extends ProviderButtonFlowFactoryWidget<_GoogleSignInButtonContainer> {
  final AuthAction? action;
  final FirebaseAuth? auth;
  final String? clientId;
  final String? redirectUri;
  @override
  final Widget child;

  const _GoogleSignInButtonContainer({
    Key? key,
    required this.child,
    this.action,
    this.auth,
    this.clientId,
    this.redirectUri,
  }) : super(key: key);

  @override
  OAuthFlow createFlow(_GoogleSignInButtonContainer widget) {
    return OAuthFlow(
      action: widget.action,
      auth: widget.auth,
      config: GoogleProviderConfiguration(
        clientId: widget.clientId,
        redirectUri: widget.redirectUri,
      ),
    );
  }
}

class GoogleSignInButton extends StatelessWidget {
  final AuthAction? action;
  final FirebaseAuth? auth;
  final String? clientId;
  final String? redirectUri;

  const GoogleSignInButton({
    Key? key,
    this.action,
    this.auth,
    this.clientId,
    this.redirectUri,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _GoogleSignInButtonContainer(
      action: action,
      auth: auth,
      clientId: clientId,
      redirectUri: redirectUri,
      child: const ProviderButton<Google>(),
    );
  }
}

class GoogleSignInIconButton extends StatelessWidget {
  final AuthAction? action;
  final FirebaseAuth? auth;
  final String? clientId;
  final String? redirectUri;

  const GoogleSignInIconButton({
    Key? key,
    this.action,
    this.auth,
    this.clientId,
    this.redirectUri,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _GoogleSignInButtonContainer(
      action: action,
      auth: auth,
      clientId: clientId,
      redirectUri: redirectUri,
      child: const ProviderIconButton<Google>(),
    );
  }
}
