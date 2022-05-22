import 'package:flutter/widgets.dart';
import 'package:flutterfire_ui_oauth/flutterfire_ui_oauth.dart';

const _twitterBlue = Color(0xff009EF7);
const _twitterWhite = Color(0xffffffff);

const _backgroundColor = ThemedColor(_twitterBlue, _twitterBlue);
const _color = ThemedColor(_twitterWhite, _twitterWhite);

const _iconSrc = ThemedIconSrc(
  'assets/twitter_icon.svg',
  'assets/twitter_icon.svg',
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
  String get assetsPackage => 'flutterfire_ui_oauth_twitter';
}
