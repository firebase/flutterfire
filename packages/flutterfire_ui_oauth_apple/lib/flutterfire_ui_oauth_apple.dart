export 'src/provider.dart' show AppleProvider;
export 'src/theme.dart' show AppleProviderButtonStyle;

import 'package:flutter/widgets.dart';
import 'package:flutterfire_ui_oauth/flutterfire_ui_oauth.dart';

class AppleSignInButton extends _AppleSignInButton {
  const factory AppleSignInButton.icon({
    Key? key,
    required ThemedOAuthProviderButtonStyle style,
    required Widget loadingIndicator,
    required Future<void> Function() onTap,
  }) = AppleSignInIconButton;

  const AppleSignInButton({
    Key? key,
    required ThemedOAuthProviderButtonStyle style,
    required Widget loadingIndicator,
    required String label,
    required Future<void> Function() onTap,
  }) : super(
          key: key,
          style: style,
          label: label,
          loadingIndicator: loadingIndicator,
          onTap: onTap,
        );
}

class AppleSignInIconButton extends AppleSignInButton {
  const AppleSignInIconButton({
    Key? key,
    required ThemedOAuthProviderButtonStyle style,
    required Widget loadingIndicator,
    required Future<void> Function() onTap,
  }) : super(
          key: key,
          style: style,
          loadingIndicator: loadingIndicator,
          onTap: onTap,
          label: '',
        );
}

class _AppleSignInButton extends StatelessWidget {
  final ThemedOAuthProviderButtonStyle style;
  final String label;
  final Widget loadingIndicator;
  final Future<void> Function() onTap;

  const _AppleSignInButton({
    Key? key,
    required this.label,
    required this.loadingIndicator,
    required this.style,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OAuthProviderButton(
      style: style,
      label: label,
      onTap: onTap,
      loadingIndicator: loadingIndicator,
    );
  }
}
