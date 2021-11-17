import 'package:flutter/widgets.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui/auth.dart';
import 'package:firebase_ui/auth/twitter.dart';
import 'package:firebase_ui/i10n.dart';

import '../configs/oauth_provider_configuration.dart';
import 'internal/oauth_provider_button.dart';
import 'internal/oauth_provider_button_style.dart';

const _TWITTER_BLUE = Color(0xff009EF7);
const _TWITTER_WHITE = Color(0xffffffff);

const _backgroundColor = ThemedColor(_TWITTER_BLUE, _TWITTER_BLUE);
const _color = ThemedColor(_TWITTER_WHITE, _TWITTER_WHITE);

const _iconSrc = ThemedIconSrc(
  'assets/icons/twitter.svg',
  'assets/icons/twitter.svg',
);

class TwitterProviderButtonStyle extends ThemedOAuthProviderButtonStyle {
  const TwitterProviderButtonStyle();

  @override
  ThemedColor get backgroundColor => _backgroundColor;

  @override
  ThemedColor get color => _color;

  @override
  ThemedIconSrc get iconSrc => _iconSrc;
}

class TwitterSignInButton extends OAuthProviderButtonWidget {
  @override
  final AuthAction? action;

  @override
  final FirebaseAuth? auth;

  final String apiKey;
  final String apiSecretKey;
  final String redirectUri;

  @override
  OAuthProviderConfiguration get providerConfig => TwitterProviderConfiguration(
        apiKey: apiKey,
        apiSecretKey: apiSecretKey,
        redirectUri: redirectUri,
      );

  @override
  final double? size;

  const TwitterSignInButton({
    Key? key,
    required this.apiKey,
    required this.apiSecretKey,
    required this.redirectUri,
    this.action,
    this.auth,
    this.size,
  }) : super(key: key);
}

class TwitterSignInIconButton extends OAuthProviderIconButtonWidget {
  @override
  final AuthAction? action;

  @override
  final FirebaseAuth? auth;

  final String apiKey;
  final String apiSecretKey;
  final String redirectUri;

  @override
  OAuthProviderConfiguration get providerConfig => TwitterProviderConfiguration(
        apiKey: apiKey,
        apiSecretKey: apiSecretKey,
        redirectUri: redirectUri,
      );

  @override
  final double? size;

  const TwitterSignInIconButton({
    Key? key,
    required this.apiKey,
    required this.apiSecretKey,
    required this.redirectUri,
    this.action,
    this.auth,
    this.size,
  }) : super(key: key);
}
