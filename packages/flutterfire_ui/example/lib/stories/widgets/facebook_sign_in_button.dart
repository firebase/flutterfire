import 'package:flutterfire_ui_example/config.dart';
import 'package:flutterfire_ui_example/stories/stories_lib/story.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui_oauth_facebook/flutterfire_ui_oauth_facebook.dart';

class FacebookSignInButtonStory extends StoryWidget {
  const FacebookSignInButtonStory({Key? key})
      : super(key: key, category: 'Widgets', title: 'FacebookSignInButton');

  @override
  Widget build(StoryElement context) {
    return FacebookSignInButton(
      clientId: FACEBOOK_CLIENT_ID,
      loadingIndicator: const CircularProgressIndicator(),
      onTap: () {
        context.notify('Button pressed');
      },
    );
  }
}
