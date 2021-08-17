import 'package:firebase_ui/firebase_ui.dart';
import 'package:flutter/widgets.dart';

import 'oauth_providers.dart';

const GOOGLE = 'google.com';
const APPLE = 'apple.com';
const TWITTER = 'twitter.com';
const FACEBOOK = 'facebook.com';

const _providers = {
  GOOGLE,
  APPLE,
  TWITTER,
  FACEBOOK,
};

bool isOAuthProvider(String providerId) {
  return _providers.contains(providerId);
}

IconData providerIconFromString(String providerId) {
  switch (providerId) {
    case GOOGLE:
      return SocialIcons.google;
    case APPLE:
      return SocialIcons.apple;
    case TWITTER:
      return SocialIcons.twitter;
    case FACEBOOK:
      return SocialIcons.facebook;
    default:
      throw Exception('Unknown provider: $providerId');
  }
}

String providerIdOf<T extends OAuthProvider>() {
  switch (T) {
    case Google:
      return 'google.com';
    case Apple:
      return 'apple.com';
    case Twitter:
      return 'twitter.com';
    case Facebook:
      return 'facebook.com';
    default:
      throw Exception('Unknown provider: $T');
  }
}

IconData providerIcon<T extends OAuthProvider>() {
  switch (T) {
    case Google:
      return SocialIcons.google;
    case Apple:
      return SocialIcons.apple;
    case Twitter:
      return SocialIcons.twitter;
    case Facebook:
      return SocialIcons.facebook;
    default:
      throw Exception('Unknown provider: $T');
  }
}
