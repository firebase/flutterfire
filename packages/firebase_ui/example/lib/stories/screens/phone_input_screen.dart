import 'package:firebase_ui/auth.dart';
import 'package:firebase_ui_example/stories/stories_lib/story.dart';
import 'package:flutter/widgets.dart';

class PhoneInputScreenStory extends StoryWidget {
  const PhoneInputScreenStory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final story = storyOf(context);

    story.category = 'Screens';
    story.title = 'PhoneInputScreen';

    return const PhoneInputScreen();
  }
}
