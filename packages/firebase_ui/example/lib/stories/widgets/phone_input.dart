import 'package:firebase_ui/auth.dart';
import 'package:firebase_ui_example/stories/stories_lib/story.dart';
import 'package:flutter/material.dart';

class PhoneInputStory extends StoryWidget {
  const PhoneInputStory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final story = storyOf(context);

    story.category = 'Widgets';
    story.title = 'Phone input';

    return PhoneInput(
      onSubmit: (String phoneNumber) {
        story.notify('Phone number submitted: $phoneNumber');
      },
    );
  }
}
