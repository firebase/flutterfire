// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutterfire_ui_example/stories/screens/forgot_password_screen.dart';
import 'package:flutterfire_ui_example/stories/screens/profile_screen.dart';
import 'package:flutterfire_ui_example/stories/screens/sms_code_input_screen.dart';
import 'package:flutterfire_ui_example/stories/views/forgot_password_view.dart';
import 'package:flutterfire_ui_example/stories/widgets/apple_sign_in_button.dart';
import 'package:flutterfire_ui_example/stories/widgets/facebook_sign_in_button.dart';
import 'package:flutterfire_ui_example/stories/widgets/firebase_database_list_view.dart';
import 'package:flutterfire_ui_example/stories/widgets/firebase_table.dart';
import 'package:flutterfire_ui_example/stories/widgets/firestore_list_view.dart';
import 'package:flutterfire_ui_example/stories/widgets/firestore_table.dart';
import 'package:flutterfire_ui_example/stories/widgets/google_sign_in_button.dart';
import 'package:flutterfire_ui_example/stories/widgets/sms_code_input.dart';
import 'package:flutterfire_ui_example/stories/widgets/twitter_sign_in_button.dart';
import 'package:flutter/material.dart';

import 'stories/screens/email_link_sign_in_screen.dart';
import 'stories/stories_lib/story.dart';

import 'stories/screens/register_screen.dart';
import 'stories/screens/sign_in_screen.dart';
import 'stories/screens/phone_input_screen.dart';
import 'stories/views/email_link_sign_in_view.dart';
import 'stories/views/login_view.dart';
import 'stories/views/phone_input_view.dart';
import 'stories/views/sms_code_input_view.dart';
import 'stories/widgets/email_form.dart';
import 'stories/widgets/oauth_provider_button.dart';
import 'stories/widgets/phone_input.dart';
import 'stories/widgets/sign_out_button.dart';
import 'stories/widgets/user_avatar.dart';

import 'init.dart'
    if (dart.library.html) 'web_init.dart'
    if (dart.library.io) 'io_init.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebase();
  runApp(const StoriesApp());
}

class StoriesApp extends StatelessWidget {
  const StoriesApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        canvasColor: Colors.white,
      ),
      home: const Stories(
        stories: [
          SignInScreenStory(),
          RegisterScreenStory(),
          PhoneInputScreenStory(),
          SMSCodeInputScreenStory(),
          ProfileScreenStory(),
          ForgotPasswordScreenStory(),
          EmailLinkSignInScreenStory(),
          LoginViewStory(),
          PhoneInputViewStory(),
          SMSCodeInputViewStory(),
          ForgotPasswordViewStory(),
          EmailLinkSignInViewStory(),
          EmailFormWidgetStory(),
          OAuthProviderButtonStory(),
          GoogleSignInButtonStory(),
          AppleSignInButtonStory(),
          FacebookSignInButtonStory(),
          TwitterSignInButtonStory(),
          PhoneInputStory(),
          SMSCodeInputStory(),
          UserAvatarStory(),
          SignOutButtonStory(),
          FirestoreListViewStory(),
          FirestoreTableStory(),
          FirebaseDatabaseListViewStory(),
          FirebaseDatabaseTableStory(),
        ],
      ),
    );
  }
}
