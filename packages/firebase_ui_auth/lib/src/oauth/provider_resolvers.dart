// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: constant_identifier_names

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'social_icons.dart';

const GOOGLE_PROVIDER_ID = 'google.com';
const APPLE_PROVIDER_ID = 'apple.com';
const TWITTER_PROVIDER_ID = 'twitter.com';
const FACEBOOK_PROVIDER_ID = 'facebook.com';
const PHONE_PROVIDER_ID = 'phone';
const PASSWORD_PROVIDER_ID = 'password';

/// Resolves an icon given a [providerId].
///
/// ```dart
/// final icon = providerIcon(context, 'google.com');
/// Icon(icon);
/// ```
IconData providerIcon(BuildContext context, String providerId) {
  final isCupertino = CupertinoUserInterfaceLevel.maybeOf(context) != null;

  switch (providerId) {
    case GOOGLE_PROVIDER_ID:
      return SocialIcons.google;
    case APPLE_PROVIDER_ID:
      return SocialIcons.apple;
    case TWITTER_PROVIDER_ID:
      return SocialIcons.twitter;
    case FACEBOOK_PROVIDER_ID:
      return SocialIcons.facebook;
    case PHONE_PROVIDER_ID:
      if (isCupertino) {
        return CupertinoIcons.phone;
      } else {
        return Icons.phone;
      }
    case PASSWORD_PROVIDER_ID:
      if (isCupertino) {
        return CupertinoIcons.mail;
      } else {
        return Icons.email_outlined;
      }
    default:
      throw Exception('Unknown provider: $providerId');
  }
}
