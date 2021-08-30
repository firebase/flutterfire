import 'package:firebase_ui/firebase_ui.dart';
import 'package:firebase_ui/src/auth/oauth/buttons/apple_provider_button_style.dart';
import 'package:firebase_ui/src/auth/oauth/buttons/facebook_provider_button_style.dart';
import 'package:firebase_ui/src/auth/oauth/buttons/google_provider_button_style.dart';
import 'package:firebase_ui/src/auth/oauth/buttons/oauth_provider_button_style.dart';
import 'package:firebase_ui/src/auth/oauth/buttons/twitter_provider_button.dart';
import 'package:flutter/widgets.dart';

import 'oauth_providers.dart';

const GOOGLE_PROVIDER_ID = 'google.com';
const APPLE_PROVIDER_ID = 'apple.com';
const TWITTER_PROVIDER_ID = 'twitter.com';
const FACEBOOK_PROVIDER_ID = 'facebook.com';

const _providers = {
  GOOGLE_PROVIDER_ID,
  APPLE_PROVIDER_ID,
  TWITTER_PROVIDER_ID,
  FACEBOOK_PROVIDER_ID,
};

bool isOAuthProvider(String providerId) {
  return _providers.contains(providerId);
}

IconData providerIconFromString(String providerId) {
  switch (providerId) {
    case GOOGLE_PROVIDER_ID:
      return SocialIcons.google;
    case APPLE_PROVIDER_ID:
      return SocialIcons.apple;
    case TWITTER_PROVIDER_ID:
      return SocialIcons.twitter;
    case FACEBOOK_PROVIDER_ID:
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

ThemedOAuthProviderButtonStyle buttonStyle<T extends OAuthProvider>() {
  switch (T) {
    case Google:
      return GoogleProviderButtonStyle();
    case Apple:
      return AppleProviderButtonStyle();
    case Twitter:
      return TwitterProviderButtonStyle();
    case Facebook:
      return FacebookProviderButtonStyle();
    default:
      throw Exception('Unknown provider: $T');
  }
}
