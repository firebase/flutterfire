import 'package:flutterfire_ui/auth/facebook.dart';
import 'package:flutterfire_ui_example/config.dart';
import 'package:flutterfire_ui_example/stories/stories_lib/story.dart';
import 'package:flutter/material.dart';

class FacebookSignInButtonStory extends StoryWidget {
  const FacebookSignInButtonStory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final story = storyOf(context);

    story.category = 'Widgets';
    story.title = 'FacebookSignInButton';

    return FacebookSignInButton(
      clientId: FACEBOOK_CLIENT_ID,
      onTap: () {
        story.notify('Button pressed');
      },
    );
  }
}
