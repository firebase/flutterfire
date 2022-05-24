import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui_example/config.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui_oauth/flutterfire_ui_oauth.dart';
import 'package:flutterfire_ui_oauth_apple/flutterfire_ui_oauth_apple.dart';
import 'package:flutterfire_ui_oauth_facebook/flutterfire_ui_oauth_facebook.dart';
import 'package:flutterfire_ui_oauth_google/flutterfire_ui_google_oauth.dart';
import 'package:flutterfire_ui_oauth_twitter/flutterfire_ui_oauth_twitter.dart';

import '../stories_lib/story.dart';

enum OAuthProviders {
  google,
  apple,
  facebook,
  twitter,
}

class OAuthProviderButtonStory extends StoryWidget {
  const OAuthProviderButtonStory({Key? key})
      : super(key: key, category: 'Widgets', title: 'OAuthProviderButton');

  @override
  Widget build(StoryElement context) {
    final selectedProvider = context.enumKnob<OAuthProviders>(
      title: 'OAuth provider',
      value: OAuthProviders.google,
      values: OAuthProviders.values,
    );

    late OAuthProvider provider;

    switch (selectedProvider) {
      case OAuthProviders.google:
        provider = GoogleProvider(clientId: GOOGLE_CLIENT_ID);
        break;
      case OAuthProviders.apple:
        provider = AppleProvider();
        break;
      case OAuthProviders.facebook:
        provider = FacebookProvider(
          clientId: FACEBOOK_CLIENT_ID,
        );
        break;
      case OAuthProviders.twitter:
        provider = TwitterProvider(
          apiKey: TWITTER_API_KEY,
          apiSecretKey: TWITTER_API_SECRET_KEY,
          redirectUri: TWITTER_REDIRECT_URI,
        );
        break;
    }

    return OAuthProviderButton(
      provider: provider,
    );
  }
}
