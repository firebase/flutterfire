import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui_example/stories/stories_lib/story.dart';
import 'package:flutter/widgets.dart';

class SMSCodeInputScreenStory extends StoryWidget {
  const SMSCodeInputScreenStory({Key? key})
      : super(key: key, category: 'Screens', title: 'SMSCodeInputScreen');

  @override
  Widget build(StoryElement context) {
    return const SMSCodeInputScreen(
      flowKey: Object(),
    );
  }
}
