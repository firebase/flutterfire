import 'package:flutterfire_ui_example/config.dart';
import 'package:flutterfire_ui_example/stories/stories_lib/story.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui_oauth_google/flutterfire_ui_google_oauth.dart';

class GoogleSignInButtonStory extends StoryWidget {
  const GoogleSignInButtonStory({Key? key})
      : super(key: key, category: 'Widgets', title: 'GoogleSignInButton');

  @override
  Widget build(StoryElement context) {
    return GoogleSignInButton(
      clientId: GOOGLE_CLIENT_ID,
      loadingIndicator: const CircularProgressIndicator(),
      onTap: () {
        context.notify('Button pressed');
      },
    );
  }
}
