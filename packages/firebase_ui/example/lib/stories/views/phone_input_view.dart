import 'package:firebase_ui/auth.dart';
import 'package:firebase_ui_example/stories/stories_lib/story.dart';
import 'package:flutter/widgets.dart';

const _flowKey = Object();

class PhoneInputViewStory extends StoryWidget {
  const PhoneInputViewStory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final story = storyOf(context);

    story.category = 'Views';
    story.title = 'PhoneInputView';

    return PhoneInputView(
      flowKey: _flowKey,
      onSubmit: (number) {
        story.notify('SMSCode submitted $number');
      },
    );
  }
}
