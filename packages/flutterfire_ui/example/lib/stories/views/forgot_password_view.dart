import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui_example/stories/stories_lib/story.dart';
import 'package:flutter/widgets.dart';

class ForgotPasswordViewStory extends StoryWidget {
  const ForgotPasswordViewStory({Key? key})
      : super(key: key, category: 'Views', title: 'ForgotPasswordView');

  @override
  Widget build(StoryElement context) {
    return const ForgotPasswordView();
  }
}
