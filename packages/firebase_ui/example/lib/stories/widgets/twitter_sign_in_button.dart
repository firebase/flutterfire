import 'package:firebase_ui/auth/twitter.dart';
import 'package:firebase_ui_example/config.dart';
import 'package:firebase_ui_example/stories/stories_lib/story.dart';
import 'package:flutter/material.dart';

class TwitterSignInButtonStory extends StoryWidget {
  const TwitterSignInButtonStory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final story = storyOf(context);

    story.category = 'Widgets';
    story.title = 'TwitterSignInButton';

    return TwitterSignInButton(
      apiKey: TWITTER_API_KEY,
      apiSecretKey: TWITTER_API_SECRET_KEY,
      redirectUri: TWITTER_REDIRECT_URI,
      onTap: () {
        story.notify('Button pressed');
      },
    );
  }
}
