// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui_example/config.dart';
import 'package:flutterfire_ui_example/stories/stories_lib/story.dart';
import 'package:flutter/material.dart';

class TwitterSignInButtonStory extends StoryWidget {
  const TwitterSignInButtonStory({Key? key})
      : super(key: key, category: 'Widgets', title: 'TwitterSignInButton');

  @override
  Widget build(StoryElement context) {
    return TwitterSignInButton(
      apiKey: TWITTER_API_KEY,
      apiSecretKey: TWITTER_API_SECRET_KEY,
      redirectUri: TWITTER_REDIRECT_URI,
      onTap: () {
        context.notify('Button pressed');
      },
    );
  }
}
