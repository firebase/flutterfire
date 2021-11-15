import 'package:flutter/widgets.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui/auth.dart';
import 'package:firebase_ui/auth/google.dart';
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

class GoogleProviderButtonStyle extends ThemedOAuthProviderButtonStyle {
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

mixin GoogleSignInButtonOptionsMixin {
  String get clientId;
  String? get redirectUri;

  final buttonStyle = GoogleProviderButtonStyle();

  late final providerConfig = GoogleProviderConfiguration(
    clientId: clientId,
    redirectUri: redirectUri,
  );

  String getLabel(FirebaseUILocalizationLabels localizations) {
    return localizations.signInWithGoogleButtonText;
  }
}

class GoogleSignInButton extends OAuthProviderButton
    with GoogleSignInButtonOptionsMixin {
  @override
  final String clientId;
  @override
  String? redirectUri;

  GoogleSignInButton({
    AuthAction? action,
    FirebaseAuth? auth,
    double size = 19,
    required this.clientId,
    this.redirectUri,
  }) : super(action: action, auth: auth, size: size);
}

class GoogleSignInIconButton extends OAuthProviderIconButton
    with GoogleSignInButtonOptionsMixin {
  @override
  final String clientId;
  @override
  final String? redirectUri;

  GoogleSignInIconButton({
    AuthAction? action,
    FirebaseAuth? auth,
    double size = 19,
    this.redirectUri,
    required this.clientId,
  }) : super(action: action, auth: auth, size: size);
}
