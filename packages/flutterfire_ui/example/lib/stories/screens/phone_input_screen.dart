import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui_example/decorations.dart';
import 'package:flutterfire_ui_example/stories/stories_lib/story.dart';

class PhoneInputScreenStory extends StoryWidget {
  const PhoneInputScreenStory({Key? key})
      : super(key: key, category: 'Screens', title: 'PhoneInputScreen');

  @override
  Widget build(StoryElement context) {
    final withImage = context.knob<bool>(title: 'With image', value: true);

    return PhoneInputScreen(
      headerBuilder: withImage ? headerIcon(Icons.phone) : null,
      sideBuilder: withImage ? sideIcon(Icons.phone) : null,
    );
  }
}
