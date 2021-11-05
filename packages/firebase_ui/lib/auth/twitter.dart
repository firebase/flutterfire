import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;

import 'package:firebase_ui/auth.dart';
import 'package:firebase_ui/src/auth/oauth/buttons/oauth_provider_button.dart';
import 'package:firebase_ui/src/auth/oauth/providers/twitter_provider.dart';
import 'package:flutter/widgets.dart';

export '../src/auth/oauth/providers/twitter_provider.dart'
    show TwitterProviderConfiguration;

class _TwitterSignInButtonContainer
    extends ProviderButtonFlowFactoryWidget<_TwitterSignInButtonContainer> {
  final AuthAction? action;
  final FirebaseAuth? auth;
  final String apiKey;
  final String apiSecretKey;
  final String redirectUri;
  @override
  final Widget child;

  const _TwitterSignInButtonContainer({
    Key? key,
    required this.child,
    required this.apiKey,
    required this.apiSecretKey,
    required this.redirectUri,
    this.action,
    this.auth,
  }) : super(key: key);

  @override
  OAuthFlow createFlow(_TwitterSignInButtonContainer widget) {
    return OAuthFlow(
      action: widget.action,
      auth: widget.auth,
      config: TwitterProviderConfiguration(
        apiKey: widget.apiKey,
        apiSecretKey: widget.apiSecretKey,
        redirectURI: widget.redirectUri,
      ),
    );
  }
}

class TwitterSignInButton extends StatelessWidget {
  final AuthAction? action;
  final FirebaseAuth? auth;
  final String apiKey;
  final String apiSecretKey;
  final String redirectUri;

  const TwitterSignInButton({
    Key? key,
    this.action,
    this.auth,
    required this.apiKey,
    required this.apiSecretKey,
    required this.redirectUri,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return _TwitterSignInButtonContainer(
      apiKey: apiKey,
      apiSecretKey: apiSecretKey,
      redirectUri: redirectUri,
      action: action,
      auth: auth,
      child: const ProviderButton<Twitter>(),
    );
  }
}

class TwitterSignInIconButton extends StatelessWidget {
  final AuthAction? action;
  final FirebaseAuth? auth;
  final String apiKey;
  final String apiSecretKey;
  final String redirectUri;

  const TwitterSignInIconButton({
    Key? key,
    this.action,
    this.auth,
    required this.apiKey,
    required this.apiSecretKey,
    required this.redirectUri,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _TwitterSignInButtonContainer(
      apiKey: apiKey,
      apiSecretKey: apiSecretKey,
      redirectUri: redirectUri,
      action: action,
      auth: auth,
      child: const ProviderIconButton<Twitter>(),
    );
  }
}
