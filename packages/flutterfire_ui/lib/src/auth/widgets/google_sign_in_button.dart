// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/widgets.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterfire_ui/auth.dart';

import 'internal/oauth_provider_button.dart';
import 'internal/oauth_provider_button_style.dart';

const _GOOGLE_BLUE = Color(0xff4285f4);
const _GOOGLE_WHITE = Color(0xffffffff);
const _GOOGLE_DARK = Color(0xff757575);

const _backgroundColor = ThemedColor(_GOOGLE_BLUE, _GOOGLE_WHITE);
const _color = ThemedColor(_GOOGLE_WHITE, _GOOGLE_DARK);
const _iconBackgroundColor = ThemedColor(_GOOGLE_WHITE, _GOOGLE_WHITE);

const _iconSrc = ThemedIconSrc(
  'assets/icons/google.svg',
  'assets/icons/google.svg',
);

class GoogleProviderButtonStyle extends ThemedOAuthProviderButtonStyle {
  @override
  ThemedColor get backgroundColor => _backgroundColor;

  @override
  ThemedColor get color => _color;

  @override
  ThemedIconSrc get iconSrc => _iconSrc;

  @override
  ThemedColor get iconBackgroundColor => _iconBackgroundColor;

  @override
  double get iconPadding => 1;
}

/// Sign-in with Google button.
///
/// {@subCategory service:auth}
/// {@subCategory type:widget}
/// {@subCategory description:A sign-in with Google button triggering the Google OAuth Flow.}
/// {@subCategory img:https://place-hold.it/400x150}
class GoogleSignInButton extends OAuthProviderButtonWidget {
  @override
  final AuthAction? action;

  @override
  final FirebaseAuth? auth;

  final String clientId;
  final String? redirectUri;

  @override
  final VoidCallback? onTap;

  @override
  OAuthProviderConfiguration get providerConfig => GoogleProviderConfiguration(
        clientId: clientId,
        redirectUri: redirectUri,
      );

  @override
  final double? size;

  const GoogleSignInButton({
    Key? key,
    required this.clientId,
    this.redirectUri,
    this.action,
    this.auth,
    this.size,
    this.onTap,
  }) : super(key: key);
}

/// Sign-in with Google icon button.
///
/// {@subCategory service:auth}
/// {@subCategory type:widget}
/// {@subCategory description:A sign-in with Google icon button triggering the Google OAuth Flow.}
/// {@subCategory img:https://place-hold.it/400x150}

class GoogleSignInIconButton extends OAuthProviderIconButtonWidget {
  @override
  final AuthAction? action;

  @override
  final FirebaseAuth? auth;

  final String clientId;
  final String? redirectUri;

  @override
  final VoidCallback? onTap;

  @override
  OAuthProviderConfiguration get providerConfig => GoogleProviderConfiguration(
        clientId: clientId,
        redirectUri: redirectUri,
      );

  @override
  final double? size;

  const GoogleSignInIconButton({
    Key? key,
    required this.clientId,
    this.action,
    this.redirectUri,
    this.auth,
    this.size,
    this.onTap,
  }) : super(key: key);
}
