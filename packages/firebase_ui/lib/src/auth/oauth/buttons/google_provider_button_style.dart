import 'package:firebase_ui/src/auth/oauth/buttons/oauth_provider_button_style.dart';
import 'package:flutter/widgets.dart';

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
