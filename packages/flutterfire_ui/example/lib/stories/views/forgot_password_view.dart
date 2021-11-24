import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui_example/stories/stories_lib/story.dart';
import 'package:flutter/widgets.dart';

class ForgotPasswordViewStory extends StoryWidget {
  const ForgotPasswordViewStory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final story = storyOf(context);

    story.category = 'Views';
    story.title = 'ForgotPasswordView';

    return ForgotPasswordView(
      onEmailSent: (context) {
        story.notify('Password reset email sent');
      },
    );
  }
}
