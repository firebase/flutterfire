// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui_example/stories/stories_lib/story.dart';
import 'package:flutter/widgets.dart';

const _flowKey = Object();

class PhoneInputViewStory extends StoryWidget {
  const PhoneInputViewStory({Key? key})
      : super(key: key, category: 'Views', title: 'PhoneInputView');

  @override
  Widget build(StoryElement context) {
    return PhoneInputView(
      flowKey: _flowKey,
      onSubmit: (number) {
        context.notify('SMSCode submitted $number');
      },
    );
  }
}
