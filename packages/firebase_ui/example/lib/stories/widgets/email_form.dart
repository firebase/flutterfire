import 'package:flutter/material.dart';
import 'package:firebase_ui/auth.dart';

import '../story.dart';

class EmailFormWidgetStory extends StoryWidget {
  const EmailFormWidgetStory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final story = storyOf(context);

    story.category = 'Widgets';
    story.title = 'Email form';

    final action =
        story.knob<AuthAction>(title: 'Auth action', value: AuthAction.signIn);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 500),
        child: EmailForm(action: action),
      ),
    );
  }
}
