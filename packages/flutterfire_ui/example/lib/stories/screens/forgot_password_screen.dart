import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui_example/stories/stories_lib/story.dart';
import 'package:flutter/widgets.dart';

class ForgotPasswordScreenStory extends StoryWidget {
  const ForgotPasswordScreenStory({Key? key})
      : super(key: key, category: 'Widgets', title: 'ForgotPasswordScreen');

  @override
  Widget build(StoryElement context) {
    return ForgotPasswordScreen(
      onEmailSent: (_) {
        context.notify('Password reset email sent');
      },
    );
  }
}
