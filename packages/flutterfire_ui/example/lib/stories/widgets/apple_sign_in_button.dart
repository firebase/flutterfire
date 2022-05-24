import 'package:flutterfire_ui_example/stories/stories_lib/story.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui_oauth_apple/flutterfire_ui_oauth_apple.dart';

class AppleSignInButtonStory extends StoryWidget {
  const AppleSignInButtonStory({Key? key})
      : super(key: key, category: 'Widgets', title: 'AppleSignInButton');

  @override
  Widget build(StoryElement context) {
    return AppleSignInButton(
      loadingIndicator: const CircularProgressIndicator(),
      onTap: () {
        context.notify('Button pressed');
      },
    );
  }
}
