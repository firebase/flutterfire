import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;

import 'package:firebase_ui/auth.dart';
import 'package:firebase_ui/src/auth/oauth/buttons/oauth_provider_button.dart';
import 'package:firebase_ui/src/auth/oauth/providers/facebook_provider.dart';
import 'package:flutter/widgets.dart';

export '../src/auth/oauth/providers/facebook_provider.dart'
    show FacebookProviderConfiguration;

class _FacebookSignInButtonContainer
    extends ProviderButtonFlowFactoryWidget<_FacebookSignInButtonContainer> {
  final AuthAction? action;
  final FirebaseAuth? auth;
  final String? clientId;
  final String? redirectUri;
  @override
  final Widget child;

  const _FacebookSignInButtonContainer({
    Key? key,
    required this.child,
    this.action,
    this.auth,
    this.clientId,
    this.redirectUri,
  }) : super(key: key);

  @override
  OAuthFlow createFlow(_FacebookSignInButtonContainer widget) {
    return OAuthFlow(
      action: widget.action,
      auth: widget.auth,
      config: FacebookProviderConfiguration(
        clientId: widget.clientId,
        redirectUri: widget.redirectUri,
      ),
    );
  }
}

class FacebookSignInButton extends StatelessWidget {
  final AuthAction? action;
  final FirebaseAuth? auth;
  final String? clientId;
  final String? redirectUri;

  const FacebookSignInButton({
    Key? key,
    this.action,
    this.auth,
    this.clientId,
    this.redirectUri,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return _FacebookSignInButtonContainer(
      action: action,
      auth: auth,
      clientId: clientId,
      redirectUri: redirectUri,
      child: const ProviderButton<Facebook>(),
    );
  }
}

class FacebookSignInIconButton extends StatelessWidget {
  final AuthAction? action;
  final FirebaseAuth? auth;
  final String? clientId;
  final String? redirectUri;

  const FacebookSignInIconButton({
    Key? key,
    this.action,
    this.auth,
    this.clientId,
    this.redirectUri,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _FacebookSignInButtonContainer(
      action: action,
      auth: auth,
      clientId: clientId,
      redirectUri: redirectUri,
      child: const ProviderIconButton<Facebook>(),
    );
  }
}
