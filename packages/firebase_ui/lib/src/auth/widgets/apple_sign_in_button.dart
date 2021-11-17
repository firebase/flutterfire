import 'package:firebase_ui/src/auth/configs/oauth_provider_configuration.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:sign_in_with_apple/sign_in_with_apple.dart'
    show WebAuthenticationOptions;

import 'package:firebase_ui/auth.dart' show AuthAction;
import 'package:firebase_ui/auth/apple.dart';

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

class AppleSignInButton extends OAuthProviderButtonWidget {
  @override
  final AuthAction? action;

  @override
  final FirebaseAuth? auth;

  final WebAuthenticationOptions? options;

  @override
  OAuthProviderConfiguration get providerConfig => AppleProviderConfiguration(
        options: options,
      );

  @override
  final double? size;

  const AppleSignInButton({
    Key? key,
    this.options,
    this.action,
    this.auth,
    this.size,
  }) : super(key: key);
}

class AppleSignInIconButton extends OAuthProviderIconButtonWidget {
  @override
  final AuthAction? action;

  @override
  final FirebaseAuth? auth;

  final WebAuthenticationOptions? options;

  @override
  OAuthProviderConfiguration get providerConfig => AppleProviderConfiguration(
        options: options,
      );

  @override
  final double? size;

  const AppleSignInIconButton({
    Key? key,
    this.options,
    this.action,
    this.auth,
    this.size,
  }) : super(key: key);
}
