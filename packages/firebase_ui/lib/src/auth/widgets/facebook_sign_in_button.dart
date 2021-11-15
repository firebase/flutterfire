import 'package:flutter/widgets.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui/auth.dart';
import 'package:firebase_ui/auth/facebook.dart';
import 'package:firebase_ui/i10n.dart';

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

mixin FacebookSignInButtonOptionsMixin {
  String get clientId;
  String? get redirectUri;

  final buttonStyle = FacebookProviderButtonStyle();

  late final providerConfig = FacebookProviderConfiguration(
    clientId: clientId,
    redirectUri: redirectUri,
  );

  String getLabel(FirebaseUILocalizationLabels localizations) {
    return localizations.signInWithFacebookButtonText;
  }
}

class FacebookSignInButton extends OAuthProviderButton
    with FacebookSignInButtonOptionsMixin {
  @override
  final String clientId;
  @override
  final String? redirectUri;

  FacebookSignInButton({
    AuthAction? action,
    FirebaseAuth? auth,
    double size = 19,
    required this.clientId,
    this.redirectUri,
  }) : super(action: action, auth: auth, size: size);
}

class FacebookSignInIconButton extends OAuthProviderIconButton
    with FacebookSignInButtonOptionsMixin {
  @override
  final String clientId;
  @override
  final String? redirectUri;

  FacebookSignInIconButton({
    AuthAction? action,
    FirebaseAuth? auth,
    double size = 19,
    required this.clientId,
    this.redirectUri,
  }) : super(action: action, auth: auth, size: size);
}
