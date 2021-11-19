import 'package:firebase_ui/auth/google.dart';
import 'package:firebase_ui_example/config.dart';
import 'package:firebase_ui_example/stories/stories_lib/story.dart';
import 'package:flutter/material.dart';

class GoogleSignInButtonStory extends StoryWidget {
  const GoogleSignInButtonStory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final story = storyOf(context);

    story.category = 'Widgets';
    story.title = 'GoogleSignInButton';

    return GoogleSignInButton(
      clientId: GOOGLE_CLIENT_ID,
      onTap: () {
        story.notify('Button pressed');
      },
    );
  }
}
