import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui_example/config.dart';
import 'package:flutterfire_ui_example/stories/stories_lib/story.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterfire_ui_oauth_apple/flutterfire_ui_oauth_apple.dart';
import 'package:flutterfire_ui_oauth_facebook/flutterfire_ui_oauth_facebook.dart';
import 'package:flutterfire_ui_oauth_google/flutterfire_ui_google_oauth.dart';
import 'package:flutterfire_ui_oauth_twitter/flutterfire_ui_oauth_twitter.dart';

class LoginViewStory extends StoryWidget {
  const LoginViewStory({Key? key})
      : super(key: key, category: 'Views', title: 'LoginView');

  @override
  Widget build(StoryElement context) {
    final action = context.enumKnob(
      title: 'Auth action',
      value: AuthAction.signIn,
      values: AuthAction.values,
    );

    final emailEnabled =
        context.knob<bool>(title: 'Email provider', value: true);
    final phoneEnabled =
        context.knob<bool>(title: 'Email provider', value: true);
    final googleEnabled =
        context.knob<bool>(title: 'Google OAuth', value: true);
    final appleEnabled = context.knob<bool>(title: 'Apple OAuth', value: true);
    final facebookEnabled = context.knob<bool>(
      title: 'Facebook OAuth',
      value: true,
    );
    final twitterEnabled = context.knob<bool>(
      title: 'Twitter OAuth',
      value: true,
    );

    return LoginView(
      action: action,
      providers: [
        if (emailEnabled) EmailAuthProvider(),
        if (phoneEnabled) PhoneAuthProvider(),
        if (googleEnabled)
          GoogleProvider(
            clientId: GOOGLE_CLIENT_ID,
          ),
        if (appleEnabled) AppleProvider(),
        if (facebookEnabled)
          FacebookProvider(
            clientId: FACEBOOK_CLIENT_ID,
          ),
        if (twitterEnabled)
          TwitterProvider(
            apiKey: TWITTER_API_KEY,
            apiSecretKey: TWITTER_API_SECRET_KEY,
            redirectUri: TWITTER_REDIRECT_URI,
          )
      ],
    );
  }
}
