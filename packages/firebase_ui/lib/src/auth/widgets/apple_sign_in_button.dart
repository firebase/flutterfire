import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:sign_in_with_apple/sign_in_with_apple.dart'
    show WebAuthenticationOptions;

import 'package:firebase_ui/auth.dart' show AuthAction;
import 'package:firebase_ui/auth/apple.dart';
import 'package:firebase_ui/i10n.dart';

import 'internal/oauth_provider_button.dart';
import 'internal/oauth_provider_button_style.dart';

const _APPLE_BLACK = Color(0xff060708);
const _APPLE_WHITE = Color(0xffffffff);

const _backgroundColor = ThemedColor(_APPLE_WHITE, _APPLE_BLACK);
const _color = ThemedColor(_APPLE_BLACK, _APPLE_WHITE);

const _iconSrc = ThemedIconSrc(
  'assets/icons/apple_light.svg',
  'assets/icons/apple_dark.svg',
);

class AppleProviderButtonStyle extends ThemedOAuthProviderButtonStyle {
  const AppleProviderButtonStyle();

  @override
  ThemedColor get backgroundColor => _backgroundColor;

  @override
  ThemedColor get color => _color;

  @override
  ThemedIconSrc get iconSrc => _iconSrc;
}

mixin AppleSignInButtonOptionsMixin {
  WebAuthenticationOptions? get options;

  final buttonStyle = const AppleProviderButtonStyle();

  late final providerConfig = AppleProviderConfiguration(options: options);

  String getLabel(FirebaseUILocalizationLabels localizations) {
    return localizations.signInWithAppleButtonText;
  }
}

class AppleSignInButton extends OAuthProviderButton
    with AppleSignInButtonOptionsMixin {
  @override
  final WebAuthenticationOptions? options;

  AppleSignInButton({
    AuthAction? action,
    FirebaseAuth? auth,
    double size = 19,
    this.options,
  }) : super(action: action, auth: auth, size: size);
}

class AppleSignInIconButton extends OAuthProviderIconButton
    with AppleSignInButtonOptionsMixin {
  @override
  final WebAuthenticationOptions? options;

  AppleSignInIconButton({
    AuthAction? action,
    FirebaseAuth? auth,
    double size = 19,
    this.options,
  }) : super(action: action, auth: auth, size: size);
}
