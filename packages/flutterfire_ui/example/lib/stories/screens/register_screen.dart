// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutterfire_ui_example/config.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../stories_lib/story.dart';

class RegisterScreenStory extends StoryWidget {
  const RegisterScreenStory({Key? key})
      : super(key: key, category: 'Screens', title: 'RegisterScreen');

  @override
  Widget build(StoryElement context) {
    final renderImage = context.knob<bool>(title: 'With image', value: true);

    final emailEnabled =
        context.knob<bool>(title: 'Email provider', value: true);
    final phoneEnabled =
        context.knob<bool>(title: 'Phone provider', value: true);
    final googleEnabled =
        context.knob<bool>(title: 'Google OAuth', value: true);
    final appleEnabled = context.knob<bool>(title: 'Apple OAuth', value: true);
    final facebookEnabled = context.knob<bool>(
      title: 'Facebook OAuth',
      value: true,
    );
    final twitterEnabled = context.knob<bool>(
      title: 'Twitter OAuth',
      value: true,
    );

    return RegisterScreen(
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
      sideBuilder: renderImage
          ? (context, constraints) {
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
            }
          : null,
      providerConfigs: [
        if (emailEnabled) const EmailProviderConfiguration(),
        if (phoneEnabled) const PhoneProviderConfiguration(),
        if (googleEnabled)
          const GoogleProviderConfiguration(
            clientId: GOOGLE_CLIENT_ID,
          ),
        if (appleEnabled) const AppleProviderConfiguration(),
        if (facebookEnabled)
          const FacebookProviderConfiguration(
            clientId: FACEBOOK_CLIENT_ID,
          ),
        if (twitterEnabled)
          const TwitterProviderConfiguration(
            apiKey: TWITTER_API_KEY,
            apiSecretKey: TWITTER_API_SECRET_KEY,
            redirectUri: TWITTER_REDIRECT_URI,
          )
      ],
    );
  }
}
