import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui_example/stories/stories_lib/story.dart';
import 'package:flutter/widgets.dart';

class ForgotPasswordScreenStory extends StoryWidget {
  const ForgotPasswordScreenStory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final story = storyOf(context);

    story.category = 'Screens';
    story.title = 'ForgotPasswordScreen';

    return ForgotPasswordScreen(
      onEmailSent: (context) {
        story.notify('Password reset email sent');
      },
    );
  }
}
