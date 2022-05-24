import 'package:flutterfire_ui_example/config.dart';
import 'package:flutterfire_ui_example/stories/stories_lib/story.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui_oauth_twitter/flutterfire_ui_oauth_twitter.dart';

class TwitterSignInButtonStory extends StoryWidget {
  const TwitterSignInButtonStory({Key? key})
      : super(key: key, category: 'Widgets', title: 'TwitterSignInButton');

  @override
  Widget build(StoryElement context) {
    return TwitterSignInButton(
      apiKey: TWITTER_API_KEY,
      apiSecretKey: TWITTER_API_SECRET_KEY,
      loadingIndicator: const CircularProgressIndicator(),
      redirectUri: TWITTER_REDIRECT_URI,
      onTap: () {
        context.notify('Button pressed');
      },
    );
  }
}
