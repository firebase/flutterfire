import 'package:firebase_ui/auth.dart';
import 'package:firebase_ui_example/stories/stories_lib/story.dart';
import 'package:flutter/material.dart';

class SMSCodeInputStory extends StoryWidget {
  const SMSCodeInputStory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final story = storyOf(context);

    story.category = 'Widgets';
    story.title = 'SMS code input';

    return SMSCodeInput(
      onSubmit: (String phoneNumber) {
        story.notify('Phone number submitted: $phoneNumber');
      },
    );
  }
}
