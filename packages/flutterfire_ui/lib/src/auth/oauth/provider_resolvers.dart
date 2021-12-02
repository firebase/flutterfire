import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'oauth_providers.dart';
import 'social_icons.dart';

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

IconData providerIcon(BuildContext context, String providerId) {
  final isCupertino = CupertinoUserInterfaceLevel.maybeOf(context) != null;

  switch (providerId) {
    case 'google.com':
      return SocialIcons.google;
    case 'apple.com':
      return SocialIcons.apple;
    case 'twitter.com':
      return SocialIcons.twitter;
    case 'facebook.com':
      return SocialIcons.facebook;
    case 'phone':
      if (isCupertino) {
        return CupertinoIcons.phone;
      } else {
        return Icons.phone;
      }
    case 'password':
      if (isCupertino) {
        return CupertinoIcons.mail;
      } else {
        return Icons.email_outlined;
      }
    default:
      throw Exception('Unknown provider: $providerId');
  }
}
