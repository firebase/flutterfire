// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart' hide OAuthProvider;
import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:firebase_ui_oauth/firebase_ui_oauth.dart' as ffui_oauth;

typedef ErrorCallback = void Function(Exception e);

/// {@template ui.auth.widgets.oauth_provider_button.oauth_button_variant}
/// Either button should display icon and text or only icon.
/// {@endtemplate}
enum OAuthButtonVariant {
  // ignore: constant_identifier_names
  icon_and_text,
  icon,
}

class _ErrorListener extends StatelessWidget {
  const _ErrorListener({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = AuthState.of(context);
    if (state is AuthFailed) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: ErrorText(exception: state.exception),
      );
    }

    return const SizedBox.shrink();
  }
}

/// {@template ui.auth.widgets.oauth_provider_button}
/// A button that is used to sign in with an OAuth provider.
/// {@endtemplate}
class OAuthProviderButton extends StatelessWidget {
  /// {@template ui.auth.widgets.oauth_provider_button.provider}
  /// An instance of [ffui_oauth.OAuthProvider] that should be used to
  /// authenticate.
  /// {@endtemplate}
  final ffui_oauth.OAuthProvider provider;

  /// {@macro ui.auth.auth_action}
  final AuthAction? action;

  /// {@macro ui.auth.auth_controller.auth}
  final FirebaseAuth? auth;

  /// {@macro ui.auth.widgets.oauth_provider_button.oauth_button_variant}
  final OAuthButtonVariant? variant;

  /// Returns a text that should be displayed on the button.
  static String resolveProviderButtonLabel(
    String providerId,
    FirebaseUILocalizationLabels labels,
  ) {
    switch (providerId) {
      case 'google.com':
        return labels.signInWithGoogleButtonText;
      case 'facebook.com':
        return labels.signInWithFacebookButtonText;
      case 'twitter.com':
        return labels.signInWithTwitterButtonText;
      case 'apple.com':
        return labels.signInWithAppleButtonText;
      default:
        throw Exception('Unknown providerId $providerId');
    }
  }

  /// {@macro ui.auth.widgets.oauth_provider_button}
  const OAuthProviderButton({
    Key? key,

    /// {@macro ui.auth.widgets.oauth_provider_button.provider}
    required this.provider,

    /// {@macro ui.auth.widgets.oauth_provider_button.oauth_button_variant}
    this.variant = OAuthButtonVariant.icon_and_text,

    /// {@macro ui.auth.auth_action}
    this.action,

    /// {@macro ui.auth.auth_controller.auth}
    this.auth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final labels = FirebaseUILocalizations.labelsOf(context);
    final brightness = Theme.of(context).brightness;

    return AuthFlowBuilder<OAuthController>(
      provider: provider,
      action: action,
      auth: auth,
      builder: (context, state, ctrl, child) {
        final button = ffui_oauth.OAuthProviderButtonBase(
          provider: provider,
          action: action,
          isLoading: state is SigningIn || state is CredentialReceived,
          onTap: () => ctrl.signIn(Theme.of(context).platform),
          overrideDefaultTapAction: true,
          loadingIndicator: LoadingIndicator(
            size: 19,
            borderWidth: 1,
            color: provider.style.color.getValue(brightness),
          ),
          label: variant == OAuthButtonVariant.icon
              ? ''
              : provider.style.label ??
                  resolveProviderButtonLabel(provider.providerId, labels),
          auth: auth,
        );

        if (variant == OAuthButtonVariant.icon) {
          return button;
        }

        return Column(
          children: [
            button,
            const _ErrorListener(),
          ],
        );
      },
    );
  }
}
