import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';

import '../stories_lib/story.dart';

class EmailFormWidgetStory extends StoryWidget {
  const EmailFormWidgetStory({Key? key})
      : super(key: key, title: 'EmailForm', category: 'Widgets');

  @override
  Widget build(StoryElement context) {
    final action = context.enumKnob(
      title: 'Auth action',
      value: AuthAction.signIn,
      values: AuthAction.values,
    );

    return Center(
      child: EmailForm(
        action: action,
        onSubmit: (email, password) {
          context.notify('Submitted $email $password');
        },
      ),
    );
  }
}
