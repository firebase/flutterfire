import 'package:firebase_ui/auth/google.dart';
import 'package:firebase_ui_example/config.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ui/auth.dart';

import '../story.dart';

class RegisterScreenStory extends StoryWidget {
  const RegisterScreenStory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final story = storyOf(context);

    story.category = 'Screens';
    story.title = 'Register screen';

    final emailEnabled = story.knob<bool>(title: 'Email provider', value: true);
    final googleEnabled = story.knob<bool>(title: 'Google OAuth', value: true);

    return RegisterScreen(
      providerConfigs: [
        if (emailEnabled) const EmailProviderConfiguration(),
        if (googleEnabled)
          const GoogleProviderConfiguration(
            clientId: GOOGLE_CLIENT_ID,
          ),
      ],
    );
  }
}
