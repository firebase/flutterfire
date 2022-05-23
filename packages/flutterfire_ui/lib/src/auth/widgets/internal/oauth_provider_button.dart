import 'package:firebase_auth/firebase_auth.dart' hide OAuthProvider;
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui/i10n.dart';
import 'package:flutterfire_ui_oauth/flutterfire_ui_oauth.dart' as ffui_oauth;

typedef ErrorCallback = void Function(Exception e);

enum OAuthButtonVariant {
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

class OAuthProviderButton extends StatelessWidget {
  final ffui_oauth.OAuthProvider provider;
  final AuthAction? action;
  final FirebaseAuth? auth;
  final OAuthButtonVariant? variant;

  static String resolveProviderButtonLabel(
      String providerId, FlutterFireUILocalizationLabels labels) {
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

  const OAuthProviderButton({
    Key? key,
    required this.provider,
    this.variant = OAuthButtonVariant.icon_and_text,
    this.action,
    this.auth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final labels = FlutterFireUILocalizations.labelsOf(context);

    return AuthFlowBuilder<OAuthController>(
      provider: provider,
      action: action,
      auth: auth,
      builder: (context, state, ctrl, child) {
        return Column(
          children: [
            ffui_oauth.OAuthProviderButton(
              provider: provider,
              action: action,
              isLoading: state is SigningIn || state is CredentialReceived,
              onTap: () => ctrl.signIn(Theme.of(context).platform),
              overrideDefaultTapAction: true,
              loadingIndicator:
                  const LoadingIndicator(size: 19, borderWidth: 1),
              label: variant == OAuthButtonVariant.icon
                  ? ''
                  : resolveProviderButtonLabel(provider.providerId, labels),
              auth: auth,
            ),
            const _ErrorListener(),
          ],
        );
      },
    );
  }
}
