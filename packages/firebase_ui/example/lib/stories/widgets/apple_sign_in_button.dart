import 'package:firebase_ui/auth/apple.dart';
import 'package:firebase_ui_example/config.dart';
import 'package:firebase_ui_example/stories/stories_lib/story.dart';
import 'package:flutter/material.dart';

class AppleSignInButtonStory extends StoryWidget {
  const AppleSignInButtonStory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final story = storyOf(context);

    story.category = 'Widgets';
    story.title = 'AppleSignInButton';

    return AppleSignInButton(
      onTap: () {
        story.notify('Button pressed');
      },
    );
  }
}
