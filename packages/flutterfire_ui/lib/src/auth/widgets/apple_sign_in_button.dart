// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;

import 'package:flutterfire_ui/auth.dart';

import 'internal/oauth_provider_button.dart';
import 'internal/oauth_provider_button_style.dart';

const _APPLE_BLACK = Color(0xff060708);
const _APPLE_WHITE = Color(0xffffffff);

const _backgroundColor = ThemedColor(_APPLE_WHITE, _APPLE_BLACK);
const _color = ThemedColor(_APPLE_BLACK, _APPLE_WHITE);

const _iconSrc = ThemedIconSrc(
  'assets/icons/apple_light.svg',
  'assets/icons/apple_dark.svg',
);

class AppleProviderButtonStyle extends ThemedOAuthProviderButtonStyle {
  const AppleProviderButtonStyle();

  @override
  ThemedColor get backgroundColor => _backgroundColor;

  @override
  ThemedColor get color => _color;

  @override
  ThemedIconSrc get iconSrc => _iconSrc;
}

/// Sign-in with Apple button.
///
/// {@subCategory service:auth}
/// {@subCategory type:widget}
/// {@subCategory description:A sign-in with Apple button triggering the Apple OAuth Flow.}
/// {@subCategory img:https://place-hold.it/400x150}
class AppleSignInButton extends OAuthProviderButtonWidget {
  @override
  final AuthAction? action;

  @override
  final FirebaseAuth? auth;

  @override
  final VoidCallback? onTap;

  @override
  OAuthProviderConfiguration get providerConfig {
    return const AppleProviderConfiguration();
  }

  @override
  final double? size;

  const AppleSignInButton({
    Key? key,
    this.action,
    this.auth,
    this.size,
    this.onTap,
  }) : super(key: key);
}

/// Sign-in with Apple icon button.
///
/// {@subCategory service:auth}
/// {@subCategory type:widget}
/// {@subCategory description:A sign-in with Apple icon button triggering the Apple OAuth Flow.}
/// {@subCategory img:https://place-hold.it/400x150}
class AppleSignInIconButton extends OAuthProviderIconButtonWidget {
  @override
  final AuthAction? action;

  @override
  final FirebaseAuth? auth;

  @override
  final VoidCallback? onTap;

  @override
  OAuthProviderConfiguration get providerConfig {
    return const AppleProviderConfiguration();
  }

  @override
  final double? size;

  const AppleSignInIconButton({
    Key? key,
    this.action,
    this.auth,
    this.size,
    this.onTap,
  }) : super(key: key);
}
