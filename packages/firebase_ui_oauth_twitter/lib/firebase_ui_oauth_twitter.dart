// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

export 'src/provider.dart' show TwitterProvider;
export 'src/theme.dart' show TwitterProviderButtonStyle;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_ui_oauth/firebase_ui_oauth.dart';

import 'src/provider.dart';

class TwitterSignInButton extends _TwitterSignInButton {
  const TwitterSignInButton({
    Key? key,
    required Widget loadingIndicator,
    required String apiKey,
    required String apiSecretKey,
    String? redirectUri,
    AuthAction? action,
    FirebaseAuth? auth,
    bool? isLoading,
    String? label,
    DifferentProvidersFoundCallback? onDifferentProvidersFound,
    SignedInCallback? onSignedIn,
    void Function()? onTap,
    bool? overrideDefaultTapAction,
    double? size,
    void Function(Exception exception)? onError,
    VoidCallback? onCanceled,
  }) : super(
          key: key,
          apiKey: apiKey,
          apiSecretKey: apiSecretKey,
          action: action,
          auth: auth,
          isLoading: isLoading ?? false,
          loadingIndicator: loadingIndicator,
          label: label,
          onDifferentProvidersFound: onDifferentProvidersFound,
          onSignedIn: onSignedIn,
          onTap: onTap,
          overrideDefaultTapAction: overrideDefaultTapAction,
          size: size,
          redirectUri: redirectUri,
          onError: onError,
          onCanceled: onCanceled,
        );
}

class TwitterSignInIconButton extends _TwitterSignInButton {
  const TwitterSignInIconButton({
    Key? key,
    required String apiKey,
    required String apiSecretKey,
    required Widget loadingIndicator,
    AuthAction? action,
    FirebaseAuth? auth,
    bool? isLoading,
    DifferentProvidersFoundCallback? onDifferentProvidersFound,
    SignedInCallback? onSignedIn,
    void Function()? onTap,
    bool? overrideDefaultTapAction,
    double? size,
    String? redirectUri,
    void Function(Exception exception)? onError,
    VoidCallback? onCanceled,
  }) : super(
          key: key,
          action: action,
          apiKey: apiKey,
          apiSecretKey: apiSecretKey,
          auth: auth,
          isLoading: isLoading ?? false,
          loadingIndicator: loadingIndicator,
          label: '',
          onDifferentProvidersFound: onDifferentProvidersFound,
          onSignedIn: onSignedIn,
          onTap: onTap,
          overrideDefaultTapAction: overrideDefaultTapAction,
          size: size,
          redirectUri: redirectUri,
          onError: onError,
          onCanceled: onCanceled,
        );
}

class _TwitterSignInButton extends StatelessWidget {
  final String label;
  final Widget loadingIndicator;
  final void Function()? onTap;
  final bool overrideDefaultTapAction;
  final bool isLoading;

  /// {@macro ui.auth.auth_action}
  final AuthAction? action;

  /// {@macro ui.auth.auth_controller.auth}
  final FirebaseAuth? auth;
  final DifferentProvidersFoundCallback? onDifferentProvidersFound;
  final SignedInCallback? onSignedIn;
  final double size;
  final String apiKey;
  final String apiSecretKey;
  final String? redirectUri;
  final void Function(Exception exception)? onError;
  final VoidCallback? onCanceled;

  const _TwitterSignInButton({
    Key? key,
    required this.apiKey,
    required this.apiSecretKey,
    required this.loadingIndicator,
    String? label,
    bool? overrideDefaultTapAction,
    this.onTap,
    this.isLoading = false,
    this.action = AuthAction.signIn,
    this.auth,
    this.onDifferentProvidersFound,
    this.onSignedIn,
    double? size,
    this.redirectUri,
    this.onError,
    this.onCanceled,
  })  : label = label ?? 'Sign in with Twitter',
        overrideDefaultTapAction = overrideDefaultTapAction ?? false,
        size = size ?? 19,
        super(key: key);

  TwitterProvider get provider => TwitterProvider(
        apiKey: apiKey,
        apiSecretKey: apiSecretKey,
        redirectUri: redirectUri,
      );

  @override
  Widget build(BuildContext context) {
    return OAuthProviderButtonBase(
      provider: provider,
      label: label,
      onTap: onTap,
      loadingIndicator: loadingIndicator,
      isLoading: isLoading,
      action: action,
      auth: auth ?? FirebaseAuth.instance,
      onDifferentProvidersFound: onDifferentProvidersFound,
      onSignedIn: onSignedIn,
      overrideDefaultTapAction: overrideDefaultTapAction,
      size: size,
      onError: onError,
      onCancelled: onCanceled,
    );
  }
}
