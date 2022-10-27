// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui_example/stories/stories_lib/story.dart';
import 'package:flutter/material.dart';

class PhoneInputStory extends StoryWidget {
  const PhoneInputStory({Key? key})
      : super(key: key, category: 'Widgets', title: 'PhoneInput');

  @override
  Widget build(StoryElement context) {
    return PhoneInput(
      initialCountryCode: 'US',
      onSubmit: (String phoneNumber) {
        context.notify('Phone number submitted: $phoneNumber');
      },
    );
  }
}
