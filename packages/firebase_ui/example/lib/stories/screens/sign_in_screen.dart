import 'package:firebase_ui/auth/google.dart';
import 'package:firebase_ui_example/config.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ui/auth.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../story.dart';

class SignInScreenStory extends StoryWidget {
  const SignInScreenStory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final story = storyOf(context);

    story.category = 'Screens';
    story.title = 'Sign in screen';

    final emailEnabled = story.knob<bool>(title: 'Email provider', value: true);
    final googleEnabled = story.knob<bool>(title: 'Google OAuth', value: true);
    final renderImage = story.knob<bool>(title: 'With image', value: true);

    return SignInScreen(
      headerBuilder: renderImage
          ? (context, constraints, _) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: SvgPicture.asset('assets/images/firebase_logo.svg'),
                ),
              );
            }
          : null,
      sideBuilder: renderImage ? (context, constraints) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(constraints.maxWidth / 8),
            child: SvgPicture.asset(
              'assets/images/firebase_logo.svg',
              width: constraints.maxWidth / 2,
              height: constraints.maxWidth / 2,
            ),
          ),
        );
      } : null,
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
