import 'package:firebase_ui/src/auth/oauth/buttons/oauth_provider_button_style.dart';
import 'package:flutter/widgets.dart';

const _TWITTER_BLUE = Color(0xff009EF7);
const _TWITTER_WHITE = Color(0xffffffff);

const _backgroundColor = ThemedColor(_TWITTER_BLUE, _TWITTER_BLUE);
const _color = ThemedColor(_TWITTER_WHITE, _TWITTER_WHITE);

const _iconSrc = ThemedIconSrc(
  'assets/icons/twitter.svg',
  'assets/icons/twitter.svg',
);

class TwitterProviderButtonStyle extends ThemedOAuthProviderButtonStyle {
  @override
  ThemedColor get backgroundColor => _backgroundColor;

  @override
  ThemedColor get color => _color;

  @override
  ThemedIconSrc get iconSrc => _iconSrc;
}
