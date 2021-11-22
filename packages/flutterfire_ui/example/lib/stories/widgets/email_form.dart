import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';

import '../stories_lib/story.dart';

class EmailFormWidgetStory extends StoryWidget {
  const EmailFormWidgetStory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final story = storyOf(context);

    story.category = 'Widgets';
    story.title = 'EmailForm';

    return Center(
      child: EmailForm(
        onSubmit: (email, password) {
          story.notify('Submitted $email $password');
        },
      ),
    );
  }
}
