import 'package:flutter/widgets.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui/auth.dart';
import 'package:firebase_ui/auth/facebook.dart';
import 'package:firebase_ui/i10n.dart';

import '../configs/oauth_provider_configuration.dart';
import 'internal/oauth_provider_button.dart';
import 'internal/oauth_provider_button_style.dart';

const _FACEBOOK_BLUE = Color(0xff1878F2);
const _FACEBOOK_WHITE = Color(0xffffffff);

const _backgroundColor = ThemedColor(_FACEBOOK_BLUE, _FACEBOOK_BLUE);
const _color = ThemedColor(_FACEBOOK_WHITE, _FACEBOOK_WHITE);

const _iconSrc = ThemedIconSrc(
  'assets/icons/facebook.svg',
  'assets/icons/facebook.svg',
);

class FacebookProviderButtonStyle extends ThemedOAuthProviderButtonStyle {
  @override
  ThemedColor get backgroundColor => _backgroundColor;

  @override
  ThemedColor get color => _color;

  @override
  ThemedIconSrc get iconSrc => _iconSrc;
}

class FacebookSignInButton extends OAuthProviderButtonWidget {
  @override
  final AuthAction? action;

  @override
  final FirebaseAuth? auth;

  final String clientId;
  final String? redirectUri;

  @override
  OAuthProviderConfiguration get providerConfig =>
      FacebookProviderConfiguration(
        clientId: clientId,
        redirectUri: redirectUri,
      );

  @override
  final double? size;

  const FacebookSignInButton({
    Key? key,
    required this.clientId,
    this.redirectUri,
    this.action,
    this.auth,
    this.size,
  }) : super(key: key);
}

class FacebookSignInIconButton extends OAuthProviderIconButtonWidget {
  @override
  final AuthAction? action;

  @override
  final FirebaseAuth? auth;

  final String clientId;
  final String? redirectUri;

  @override
  OAuthProviderConfiguration get providerConfig =>
      FacebookProviderConfiguration(
        clientId: clientId,
        redirectUri: redirectUri,
      );

  @override
  final double? size;

  const FacebookSignInIconButton({
    Key? key,
    required this.clientId,
    this.redirectUri,
    this.action,
    this.auth,
    this.size,
  }) : super(key: key);
}
