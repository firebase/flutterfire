// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui_example/decorations.dart';
import 'package:flutterfire_ui_example/stories/stories_lib/story.dart';

class ForgotPasswordScreenStory extends StoryWidget {
  const ForgotPasswordScreenStory({Key? key})
      : super(key: key, category: 'Screens', title: 'ForgotPasswordScreen');

  @override
  Widget build(StoryElement context) {
    final withImage = context.knob<bool>(title: 'With image', value: true);

    return ForgotPasswordScreen(
      headerBuilder: withImage ? headerIcon(Icons.lock) : null,
      sideBuilder: withImage ? sideIcon(Icons.lock) : null,
    );
  }
}
