import 'package:firebase_ui/auth/apple.dart';
import 'package:firebase_ui/auth/facebook.dart';
import 'package:firebase_ui/auth/google.dart';
import 'package:firebase_ui/auth/twitter.dart';
import 'package:firebase_ui_example/config.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ui/auth.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../stories_lib/story.dart';

class RegisterScreenStory extends StoryWidget {
  const RegisterScreenStory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final story = storyOf(context);

    story.category = 'Screens';
    story.title = 'RegisterScreen';

    final renderImage = story.knob<bool>(title: 'With image', value: true);

    final emailEnabled = story.knob<bool>(title: 'Email provider', value: true);
    final phoneEnabled = story.knob<bool>(title: 'Phone provider', value: true);
    final googleEnabled = story.knob<bool>(title: 'Google OAuth', value: true);
    final appleEnabled = story.knob<bool>(title: 'Apple OAuth', value: true);
    final facebookEnabled = story.knob<bool>(
      title: 'Facebook OAuth',
      value: true,
    );
    final twitterEnabled = story.knob<bool>(
      title: 'Twitter OAuth',
      value: true,
    );

    return RegisterScreen(
      headerBuilder: renderImage
          ? (context, constraints, _) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: SvgPicture.asset('assets/images/firebase_logo.svg'),
                ),
              );
            }
          : null,
      sideBuilder: renderImage
          ? (context, constraints) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(constraints.maxWidth / 8),
                  child: SvgPicture.asset(
                    'assets/images/firebase_logo.svg',
                    width: constraints.maxWidth / 2,
                    height: constraints.maxWidth / 2,
                  ),
                ),
              );
            }
          : null,
      providerConfigs: [
        if (emailEnabled) const EmailProviderConfiguration(),
        if (phoneEnabled) const PhoneProviderConfiguration(),
        if (googleEnabled)
          const GoogleProviderConfiguration(
            clientId: GOOGLE_CLIENT_ID,
          ),
        if (appleEnabled) const AppleProviderConfiguration(),
        if (facebookEnabled)
          const FacebookProviderConfiguration(
            clientId: FACEBOOK_CLIENT_ID,
          ),
        if (twitterEnabled)
          const TwitterProviderConfiguration(
            apiKey: TWITTER_API_KEY,
            apiSecretKey: TWITTER_API_SECRET_KEY,
            redirectUri: TWITTER_REDIRECT_URI,
          )
      ],
    );
  }
}
