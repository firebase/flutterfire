// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui_example/stories/stories_lib/story.dart';
import 'package:flutter/widgets.dart';

class UserAvatarStory extends StoryWidget {
  const UserAvatarStory({Key? key})
      : super(key: key, category: 'Widgets', title: 'UserAvatar');

  @override
  Widget build(BuildContext context) => const UserAvatar();
}
