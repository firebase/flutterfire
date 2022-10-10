// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/widgets.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterfire_ui/auth.dart';

import 'internal/oauth_provider_button.dart';
import 'internal/oauth_provider_button_style.dart';

const _FACEBOOK_BLUE = Color(0xff1878F2);
const _FACEBOOK_WHITE = Color(0xffffffff);

const _backgroundColor = ThemedColor(_FACEBOOK_BLUE, _FACEBOOK_BLUE);
const _color = ThemedColor(_FACEBOOK_WHITE, _FACEBOOK_WHITE);

const _iconSrc = ThemedIconSrc(
  'assets/icons/facebook.svg',
  'assets/icons/facebook.svg',
);

class FacebookProviderButtonStyle extends ThemedOAuthProviderButtonStyle {
  @override
  ThemedColor get backgroundColor => _backgroundColor;

  @override
  ThemedColor get color => _color;

  @override
  ThemedIconSrc get iconSrc => _iconSrc;
}

/// Sign-in with Facebook button.
///
/// {@subCategory service:auth}
/// {@subCategory type:widget}
/// {@subCategory description:A sign-in with Facebook button triggering the Facebook OAuth Flow.}
/// {@subCategory img:https://place-hold.it/400x150}
class FacebookSignInButton extends OAuthProviderButtonWidget {
  @override
  final AuthAction? action;

  @override
  final FirebaseAuth? auth;

  final String clientId;
  final String? redirectUri;

  @override
  final VoidCallback? onTap;

  @override
  OAuthProviderConfiguration get providerConfig =>
      FacebookProviderConfiguration(
        clientId: clientId,
        redirectUri: redirectUri,
      );

  @override
  final double? size;

  const FacebookSignInButton({
    Key? key,
    required this.clientId,
    this.redirectUri,
    this.action,
    this.auth,
    this.size,
    this.onTap,
  }) : super(key: key);
}

/// Sign-in with Facebook icon button.
///
/// {@subCategory service:auth}
/// {@subCategory type:widget}
/// {@subCategory description:A sign-in with Facebook icon button triggering the Facebook OAuth Flow.}
/// {@subCategory img:https://place-hold.it/400x150}
class FacebookSignInIconButton extends OAuthProviderIconButtonWidget {
  @override
  final AuthAction? action;

  @override
  final FirebaseAuth? auth;

  final String clientId;
  final String? redirectUri;

  @override
  final VoidCallback? onTap;

  @override
  OAuthProviderConfiguration get providerConfig =>
      FacebookProviderConfiguration(
        clientId: clientId,
        redirectUri: redirectUri,
      );

  @override
  final double? size;

  const FacebookSignInIconButton({
    Key? key,
    required this.clientId,
    this.redirectUri,
    this.action,
    this.auth,
    this.size,
    this.onTap,
  }) : super(key: key);
}
