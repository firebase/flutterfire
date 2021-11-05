import 'package:firebase_ui/src/auth/oauth/providers/apple_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'package:firebase_ui/src/auth/oauth/buttons/oauth_provider_button.dart';

import '../auth.dart';

export '../src/auth/oauth/providers/apple_provider.dart'
    show AppleProviderConfiguration;

class _AppleSignInButtonContainer
    extends ProviderButtonFlowFactoryWidget<_AppleSignInButtonContainer> {
  final AuthAction? action;
  final FirebaseAuth? auth;
  final WebAuthenticationOptions? options;

  @override
  final Widget child;

  const _AppleSignInButtonContainer({
    Key? key,
    required this.child,
    this.action,
    this.auth,
    this.options,
  }) : super(key: key);

  @override
  OAuthFlow createFlow(_AppleSignInButtonContainer widget) {
    return OAuthFlow(
      action: widget.action,
      auth: widget.auth,
      config: AppleProviderConfiguration(options: options),
    );
  }
}

class AppleSignInButton extends StatelessWidget {
  final AuthAction? action;
  final FirebaseAuth? auth;
  final WebAuthenticationOptions? options;

  const AppleSignInButton({
    Key? key,
    this.action,
    this.auth,
    this.options,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _AppleSignInButtonContainer(
      action: action,
      auth: auth,
      options: options,
      child: const ProviderButton<Apple>(),
    );
  }
}

class AppleSignInIconButton extends StatelessWidget {
  final AuthAction? action;
  final FirebaseAuth? auth;
  final WebAuthenticationOptions? options;

  const AppleSignInIconButton({
    Key? key,
    this.action,
    this.auth,
    this.options,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _AppleSignInButtonContainer(
      action: action,
      auth: auth,
      options: options,
      child: const ProviderIconButton<Apple>(),
    );
  }
}
