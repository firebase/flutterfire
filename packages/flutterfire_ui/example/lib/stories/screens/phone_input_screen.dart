import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui_example/stories/stories_lib/story.dart';
import 'package:flutter/widgets.dart';

class PhoneInputScreenStory extends StoryWidget {
  const PhoneInputScreenStory({Key? key})
      : super(key: key, category: 'Screens', title: 'PhoneInputScreen');

  @override
  Widget build(StoryElement context) => const PhoneInputScreen();
}
