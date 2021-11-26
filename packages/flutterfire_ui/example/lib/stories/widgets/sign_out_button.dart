import 'package:flutter/widgets.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui_example/stories/stories_lib/story.dart';

class SignOutButtonStory extends StoryWidget {
  const SignOutButtonStory({Key? key})
      : super(key: key, category: 'Widgets', title: 'SignOutButton');

  @override
  Widget build(BuildContext context) => const SignOutButton();
}
