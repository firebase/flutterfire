import 'package:flutter/widgets.dart';
import 'package:flutterfire_ui_oauth/flutterfire_ui_oauth.dart';

const _facebookBlue = Color(0xff1878F2);
const _facebookWhite = Color(0xffffffff);

const _backgroundColor = ThemedColor(_facebookBlue, _facebookBlue);
const _color = ThemedColor(_facebookWhite, _facebookWhite);

const _iconSrc = ThemedIconSrc(
  'assets/facebook_icon.svg',
  'assets/facebook_icon.svg',
);

class FacebookProviderButtonStyle extends ThemedOAuthProviderButtonStyle {
  const FacebookProviderButtonStyle();

  @override
  ThemedColor get backgroundColor => _backgroundColor;

  @override
  ThemedColor get color => _color;

  @override
  ThemedIconSrc get iconSrc => _iconSrc;

  @override
  String get assetsPackage => 'flutterfire_ui_oauth_facebook';
}
