import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui/auth/apple.dart';
import 'package:flutterfire_ui/auth/facebook.dart';
import 'package:flutterfire_ui/auth/google.dart';
import 'package:flutterfire_ui/auth/twitter.dart';
import 'package:flutterfire_ui_example/config.dart';
import 'package:flutterfire_ui_example/stories/stories_lib/story.dart';
import 'package:flutter/widgets.dart';

class ProfileScreenStory extends StoryWidget {
  const ProfileScreenStory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final story = storyOf(context);

    story.category = 'Screens';
    story.title = 'ProfileScreen';

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

    return ProfileScreen(
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
