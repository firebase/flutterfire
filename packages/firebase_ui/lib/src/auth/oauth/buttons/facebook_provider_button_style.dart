import 'package:firebase_ui/src/auth/oauth/buttons/oauth_provider_button_style.dart';
import 'package:flutter/widgets.dart';

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
