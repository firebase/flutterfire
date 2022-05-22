export 'src/provider.dart' show GoogleProvider;
export 'src/theme.dart' show GoogleProviderButtonStyle;

import 'package:flutter/widgets.dart';
import 'package:flutterfire_ui_oauth/flutterfire_ui_oauth.dart';

class GoogleSignInButton extends _GoogleSignInButton {
  const factory GoogleSignInButton.icon({
    Key? key,
    required ThemedOAuthProviderButtonStyle style,
    required Widget loadingIndicator,
    required Future<void> Function() onTap,
  }) = GoogleSignInIconButton;

  const GoogleSignInButton({
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

class GoogleSignInIconButton extends GoogleSignInButton {
  const GoogleSignInIconButton({
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

class _GoogleSignInButton extends StatelessWidget {
  final ThemedOAuthProviderButtonStyle style;
  final String label;
  final Widget loadingIndicator;
  final Future<void> Function() onTap;

  const _GoogleSignInButton({
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
