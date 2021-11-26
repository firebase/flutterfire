import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui_example/stories/stories_lib/story.dart';
import 'package:flutter/widgets.dart';

class UserAvatarStory extends StoryWidget {
  const UserAvatarStory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final story = storyOf(context);
    story.category = 'Widgets';
    story.title = 'UserAvatar';

    return const UserAvatar();
  }
}
