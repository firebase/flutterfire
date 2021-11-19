import 'package:firebase_ui/auth.dart';
import 'package:firebase_ui/auth/apple.dart';
import 'package:firebase_ui/auth/facebook.dart';
import 'package:firebase_ui/auth/google.dart';
import 'package:firebase_ui/auth/twitter.dart';
import 'package:firebase_ui_example/config.dart';
import 'package:firebase_ui_example/stories/stories_lib/story.dart';
import 'package:flutter/material.dart';

enum OAuthProviders {
  google,
  apple,
  facebook,
  twitter,
}

class OAuthProviderButtonStory extends StoryWidget {
  const OAuthProviderButtonStory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final story = storyOf(context);

    story.category = 'Widgets';
    story.title = 'OAuth Button';

    final provider = story.enumKnob<OAuthProviders>(
      title: 'OAuth provider',
      value: OAuthProviders.google,
      values: OAuthProviders.values,
    );

    late OAuthProviderConfiguration config;

    switch (provider) {
      case OAuthProviders.google:
        config = const GoogleProviderConfiguration(clientId: GOOGLE_CLIENT_ID);
        break;
      case OAuthProviders.apple:
        config = const AppleProviderConfiguration();
        break;
      case OAuthProviders.facebook:
        config = const FacebookProviderConfiguration(
          clientId: FACEBOOK_CLIENT_ID,
        );
        break;
      case OAuthProviders.twitter:
        config = const TwitterProviderConfiguration(
          apiKey: TWITTER_API_KEY,
          apiSecretKey: TWITTER_API_SECRET_KEY,
          redirectUri: TWITTER_REDIRECT_URI,
        );
        break;
    }

    return OAuthProviderButton(
      providerConfig: config,
      onTap: () {
        story.notify('Button pressed');
      },
    );
  }
}
