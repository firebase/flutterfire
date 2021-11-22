import 'package:flutter/widgets.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui_example/stories/stories_lib/story.dart';

class SignOutButtonStory extends StoryWidget {
  const SignOutButtonStory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final story = storyOf(context);

    story.category = 'Widgets';
    story.title = 'SignOutButton';
    return const SignOutButton();
  }
}
