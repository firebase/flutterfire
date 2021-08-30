import 'package:firebase_ui/src/auth/oauth/buttons/oauth_provider_button_style.dart';
import 'package:flutter/widgets.dart';

const _APPLE_BLACK = Color(0xff060708);
const _APPLE_WHITE = Color(0xffffffff);

const _backgroundColor = ThemedColor(_APPLE_WHITE, _APPLE_BLACK);
const _color = ThemedColor(_APPLE_BLACK, _APPLE_WHITE);

const _iconSrc = ThemedIconSrc(
  'assets/icons/apple_light.svg',
  'assets/icons/apple_dark.svg',
);

class AppleProviderButtonStyle extends ThemedOAuthProviderButtonStyle {
  @override
  ThemedColor get backgroundColor => _backgroundColor;

  @override
  ThemedColor get color => _color;

  @override
  ThemedIconSrc get iconSrc => _iconSrc;
}
