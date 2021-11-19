import 'package:firebase_ui/auth.dart';
import 'package:firebase_ui/auth/apple.dart';
import 'package:firebase_ui/auth/facebook.dart';
import 'package:firebase_ui/auth/google.dart';
import 'package:firebase_ui/auth/twitter.dart';
import 'package:firebase_ui_example/config.dart';
import 'package:firebase_ui_example/stories/stories_lib/story.dart';
import 'package:flutter/widgets.dart';

class LoginViewStory extends StoryWidget {
  const LoginViewStory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final story = storyOf(context);

    story.category = 'Views';
    story.title = 'LoginView';

    final action = story.enumKnob(
      title: 'Auth action',
      value: AuthAction.signIn,
      values: AuthAction.values,
    );

    final emailEnabled = story.knob<bool>(title: 'Email provider', value: true);
    final phoneEnabled = story.knob<bool>(title: 'Email provider', value: true);
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

    return LoginView(
      action: action,
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
