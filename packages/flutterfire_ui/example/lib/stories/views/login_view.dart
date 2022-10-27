// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui_example/config.dart';
import 'package:flutterfire_ui_example/stories/stories_lib/story.dart';
import 'package:flutter/widgets.dart';

class LoginViewStory extends StoryWidget {
  const LoginViewStory({Key? key})
      : super(key: key, category: 'Views', title: 'LoginView');

  @override
  Widget build(StoryElement context) {
    final action = context.enumKnob(
      title: 'Auth action',
      value: AuthAction.signIn,
      values: AuthAction.values,
    );

    final emailEnabled =
        context.knob<bool>(title: 'Email provider', value: true);
    final phoneEnabled =
        context.knob<bool>(title: 'Email provider', value: true);
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

    return LoginView(
      action: action,
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
