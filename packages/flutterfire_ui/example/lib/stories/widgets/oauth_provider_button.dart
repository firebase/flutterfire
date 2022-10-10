// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui_example/config.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui_example/stories/stories_lib/story.dart';

enum OAuthProviders {
  google,
  apple,
  facebook,
  twitter,
}

class OAuthProviderButtonStory extends StoryWidget {
  const OAuthProviderButtonStory({Key? key})
      : super(key: key, category: 'Widgets', title: 'OAuthProviderButton');

  @override
  Widget build(StoryElement context) {
    final provider = context.enumKnob<OAuthProviders>(
      title: 'OAuth provider',
      value: OAuthProviders.google,
      values: OAuthProviders.values,
    );

    late OAuthProviderConfiguration config;

    switch (provider) {
      case OAuthProviders.google:
        config = const GoogleProviderConfiguration(clientId: GOOGLE_CLIENT_ID);
        break;
      case OAuthProviders.apple:
        config = const AppleProviderConfiguration();
        break;
      case OAuthProviders.facebook:
        config = const FacebookProviderConfiguration(
          clientId: FACEBOOK_CLIENT_ID,
        );
        break;
      case OAuthProviders.twitter:
        config = const TwitterProviderConfiguration(
          apiKey: TWITTER_API_KEY,
          apiSecretKey: TWITTER_API_SECRET_KEY,
          redirectUri: TWITTER_REDIRECT_URI,
        );
        break;
    }

    return OAuthProviderButton(
      providerConfig: config,
      onTap: () {
        context.notify('Button pressed');
      },
    );
  }
}
