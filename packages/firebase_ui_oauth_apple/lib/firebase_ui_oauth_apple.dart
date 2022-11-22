// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

export 'src/provider.dart' show AppleProvider;
export 'src/theme.dart' show AppleProviderButtonStyle;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_ui_oauth/firebase_ui_oauth.dart';

import 'src/provider.dart';

class AppleSignInButton extends _AppleSignInButton {
  const AppleSignInButton({
    Key? key,
    required Widget loadingIndicator,
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
          onError: onError,
          onCanceled: onCanceled,
        );
}

class AppleSignInIconButton extends _AppleSignInButton {
  const AppleSignInIconButton({
    Key? key,
    required Widget loadingIndicator,
    AuthAction? action,
    FirebaseAuth? auth,
    bool? isLoading,
    DifferentProvidersFoundCallback? onDifferentProvidersFound,
    SignedInCallback? onSignedIn,
    void Function()? onTap,
    bool? overrideDefaultTapAction,
    double? size,
    void Function(Exception exception)? onError,
    VoidCallback? onCanceled,
  }) : super(
          key: key,
          action: action,
          auth: auth,
          isLoading: isLoading ?? false,
          loadingIndicator: loadingIndicator,
          label: '',
          onDifferentProvidersFound: onDifferentProvidersFound,
          onSignedIn: onSignedIn,
          onTap: onTap,
          overrideDefaultTapAction: overrideDefaultTapAction,
          size: size,
          onError: onError,
          onCanceled: onCanceled,
        );
}

class _AppleSignInButton extends StatelessWidget {
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
  final void Function(Exception exception)? onError;
  final VoidCallback? onCanceled;

  const _AppleSignInButton({
    Key? key,
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
    this.onError,
    this.onCanceled,
  })  : label = label ?? 'Sign in with Apple',
        overrideDefaultTapAction = overrideDefaultTapAction ?? false,
        size = size ?? 19,
        super(key: key);

  AppleProvider get provider => AppleProvider();

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
