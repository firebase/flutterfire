import 'package:flutter/widgets.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui/auth.dart';
import 'package:firebase_ui/auth/twitter.dart';
import 'package:firebase_ui/i10n.dart';

import 'internal/oauth_provider_button.dart';
import 'internal/oauth_provider_button_style.dart';

const _GOOGLE_BLUE = Color(0xff4285f4);
const _GOOGLE_WHITE = Color(0xffffffff);
const _GOOGLE_DARK = Color(0xff757575);

const _backgroundColor = ThemedColor(_GOOGLE_BLUE, _GOOGLE_WHITE);
const _color = ThemedColor(_GOOGLE_WHITE, _GOOGLE_DARK);
const _iconBackgroundColor = ThemedColor(_GOOGLE_WHITE, _GOOGLE_WHITE);

const _iconSrc = ThemedIconSrc(
  'assets/icons/google.svg',
  'assets/icons/google.svg',
);

class TwitterProviderButtonStyle extends ThemedOAuthProviderButtonStyle {
  const TwitterProviderButtonStyle();
  @override
  ThemedColor get backgroundColor => _backgroundColor;

  @override
  ThemedColor get color => _color;

  @override
  ThemedIconSrc get iconSrc => _iconSrc;

  @override
  ThemedColor get iconBackgroundColor => _iconBackgroundColor;

  @override
  double get iconPadding => 1;
}

mixin TwitterSignInButtonOptionsMixin {
  String get apiKey;
  String get apiSecretKey;
  String get redirectUri;

  final buttonStyle = const TwitterProviderButtonStyle();

  late final providerConfig = TwitterProviderConfiguration(
    apiKey: apiKey,
    apiSecretKey: apiSecretKey,
    redirectUri: redirectUri,
  );

  String getLabel(FirebaseUILocalizationLabels localizations) {
    return localizations.signInWithTwitterButtonText;
  }
}

class TwitterSignInButton extends OAuthProviderButton
    with TwitterSignInButtonOptionsMixin {
  @override
  final String apiKey;
  @override
  final String apiSecretKey;
  @override
  final String redirectUri;

  TwitterSignInButton({
    AuthAction? action,
    FirebaseAuth? auth,
    double size = 19,
    required this.apiKey,
    required this.apiSecretKey,
    required this.redirectUri,
  }) : super(action: action, auth: auth, size: size);
}

class TwitterSignInIconButton extends OAuthProviderButton
    with TwitterSignInButtonOptionsMixin {
  @override
  final String apiKey;
  @override
  final String apiSecretKey;
  @override
  final String redirectUri;

  TwitterSignInIconButton({
    AuthAction? action,
    FirebaseAuth? auth,
    double size = 19,
    required this.apiKey,
    required this.apiSecretKey,
    required this.redirectUri,
  }) : super(action: action, auth: auth, size: size);
}
