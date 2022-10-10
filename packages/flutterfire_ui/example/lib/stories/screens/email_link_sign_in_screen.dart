// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui_example/decorations.dart';
import 'package:flutterfire_ui_example/stories/stories_lib/story.dart';

class EmailLinkSignInScreenStory extends StoryWidget {
  const EmailLinkSignInScreenStory({Key? key})
      : super(key: key, category: 'Screens', title: 'EmailLinkSignInScreen');

  @override
  Widget build(StoryElement context) {
    final withImage = context.knob<bool>(title: 'With image', value: true);

    return EmailLinkSignInScreen(
      config: EmailLinkProviderConfiguration(
        actionCodeSettings: ActionCodeSettings(
          url: 'https://reactnativefirebase.page.link',
          handleCodeInApp: true,
          androidMinimumVersion: '12',
          androidPackageName:
              'io.flutter.plugins.flutterfire_ui.flutterfire_ui_example',
          iOSBundleId: 'io.flutter.plugins.flutterfireui.flutterfireUIExample',
        ),
      ),
      headerBuilder: withImage ? headerIcon(Icons.link) : null,
      sideBuilder: withImage ? sideIcon(Icons.link) : null,
    );
  }
}
