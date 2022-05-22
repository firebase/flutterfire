import 'package:flutter/widgets.dart';
import 'package:flutterfire_ui_oauth/flutterfire_ui_oauth.dart';

const _appleBlack = Color(0xff060708);
const _appleWhite = Color(0xffffffff);

const _backgroundColor = ThemedColor(_appleWhite, _appleBlack);
const _color = ThemedColor(_appleBlack, _appleWhite);

const _iconSrc = ThemedIconSrc(
  'assets/apple_icon_light.svg',
  'assets/apple_icon_dark.svg',
);

class AppleProviderButtonStyle extends ThemedOAuthProviderButtonStyle {
  const AppleProviderButtonStyle();

  @override
  ThemedColor get backgroundColor => _backgroundColor;

  @override
  ThemedColor get color => _color;

  @override
  ThemedIconSrc get iconSrc => _iconSrc;

  @override
  String get assetsPackage => 'flutterfire_ui_oauth_apple';
}
